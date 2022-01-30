//
//  TableViewController.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 28/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Cocoa
import DifferenceKit

final class SongTableViewController: NSViewController {

    private let songHandlers: SongHandlers
    private let droppedFileURLHandler: DroppedFileURLHandler

    private let dragDropScrollingTableView = DragDropScrollingTableView()

    private var tableView: NSTableView {
        return dragDropScrollingTableView.tableView
    }

    private let columns: [NSTableColumn]

    private let measuringView = NSTextView()

    /// - Warning: do not access this directly, it is boxed by `songs`.
    private var _songs = [SongViewModel]()
    private var songs: [SongViewModel] {
        get {
            return _songs
        }
        set {
            let stagedChangeset = StagedChangeset(source: _songs, target: newValue)
            guard stagedChangeset.isEmpty == false else { return }
            let threshold = _songs.count / 2
            tableView.reload(
                using: stagedChangeset,
                with: .effectFade,
                interrupt: { $0.changeCount > threshold },
                setData: { _songs = $0 }
            )
        }
    }

    // MARK: - Init

    init(
        songHandlers: SongHandlers,
        songListEventHandler: SongListEventHandler,
        droppedFileURLHandler: @escaping DroppedFileURLHandler
    ) {
        self.songHandlers = songHandlers
        self.droppedFileURLHandler = droppedFileURLHandler
        columns = Constants.SongList.ColumnID.allCases.map { columnID in
            let column = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier(
                    rawValue: columnID.rawValue
                )
            )
            column.title = columnID.displayName
            column.sortDescriptorPrototype = NSSortDescriptor(
                key: columnID.rawValue,
                ascending: true
            )
            column.isHidden = columnID == .path
            return column
        }
        measuringView.textContainer?.maximumNumberOfLines = 1
        super.init(nibName: nil, bundle: nil)
        songListEventHandler.delegate = self
    }

    // MARK: - Overrides

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = dragDropScrollingTableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sortDescriptors = [
            NSSortDescriptor(
                key: Constants.SongList.ColumnID.path.rawValue,
                ascending: true
            )
        ]
        tableView.gridStyleMask = [
            .solidHorizontalGridLineMask,
            .solidVerticalGridLineMask,
        ]
        tableView.dataSource = self
        tableView.delegate = self
        columns.forEach {
            tableView.addTableColumn($0)
        }
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsMultipleSelection = true

        dragDropScrollingTableView.delegate = self
        dragDropScrollingTableView.hasVerticalScroller = true
        dragDropScrollingTableView.hasHorizontalScroller = true

        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(
                title: "Select All",
                action: #selector(selectAllMenuItem(_:)),
                keyEquivalent: "a"
            )
        )
        menu.addItem(
            NSMenuItem(
                title: "Write key to tags",
                action: #selector(writeKeyToTagsMenuItem(_:)),
                keyEquivalent: "t"
            )
        )
        let deleteItem = NSMenuItem(
            title: "Delete selected rows",
            action: #selector(deleteMenuItem(_:)),
            keyEquivalent: NSString(format: "%c", NSDeleteCharacter) as String
        )
        deleteItem.keyEquivalentModifierMask = []
        menu.addItem(
            deleteItem
        )
        menu.addItem(
            NSMenuItem(
                title: "Show in Finder",
                action: #selector(showInFinderMenuItem(_:)),
                keyEquivalent: ""
            )
        )
        tableView.menu = menu
    }
}

// MARK: - Interface

extension SongTableViewController {

    func setIsEnabled(_ isEnabled: Bool) {
        tableView.isEnabled = isEnabled
    }

    func setModel(_ model: SongListViewModel) {
        self.songs = SongTableViewController.sort(
            songs: model.songs,
            descriptors: tableView.sortDescriptors
        )
    }

    func setDragDropIsEnabled(_ dragDropIsEnabled: Bool) {
        dragDropScrollingTableView.setDragDropIsEnabled(dragDropIsEnabled)
    }
}

// MARK: - NSTableViewDataSource

extension SongTableViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return songs.count
    }

    func tableView(
        _ tableView: NSTableView,
        objectValueFor tableColumn: NSTableColumn?,
        row: Int
    ) -> Any? {
        guard let columnIDRawValue = tableColumn?.identifier.rawValue else {
            fatalError("no column identifier")
        }
        guard let columnID = Constants.SongList.ColumnID(rawValue: columnIDRawValue) else {
            fatalError("invalid column identifier \(columnIDRawValue)")
        }
        guard (0..<songs.count).contains(row) else {
            fatalError("index out of range")
        }

        return songs[row].textValues[columnID.elementIndex] ?? String()
    }
}

// MARK: - NSTableViewDelegate

extension SongTableViewController: NSTableViewDelegate {

    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        guard let columnIDRawValue = tableColumn?.identifier.rawValue else {
            fatalError("no column identifier")
        }
        guard let columnID = Constants.SongList.ColumnID(rawValue: columnIDRawValue) else {
            fatalError("invalid column identifier \(columnIDRawValue)")
        }
        guard (0..<songs.count).contains(row) else {
            fatalError("index out of range")
        }

        let song = songs[row]

        // TODO choose colours for accessibility and theming etc
        let (extendedColumnIDRaw, textColor): (String, NSColor) = {
            switch columnID {
            case .path,
                 .filename:
                return ("FILE", .secondaryLabelColor)
            case .title,
                 .artist,
                 .album,
                 .comment,
                 .grouping,
                 .key:
                return ("TAG", .labelColor)
            case .resultString:
                switch song.result {
                case .none:
                    return ("RESULT_EMPTY", .clear)
                case .success:
                    return ("RESULT_SUCCESS", .green)
                case .failure(let error):
                    switch error {
                    case .existingMetadata:
                        return ("RESULT_SKIPPED", .secondaryLabelColor)
                    case .decoder:
                        return ("RESULT_ERROR", .red)
                    }
                }
            }
        }()

        let identifier = NSUserInterfaceItemIdentifier(extendedColumnIDRaw)

        if let existingView = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView {
            return existingView
        }

        // Create a text field for the cell
        let textField = NSTextField()
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isBordered = false
        textField.controlSize = .small
        textField.isEditable = false
        textField.font = .systemFont(ofSize: 12)
        textField.textColor = textColor

        // Create a cell
        let view = NSTableCellView()
        view.identifier = identifier
        view.addSubview(textField)
        view.textField = textField

        // Constrain the text field within the cell
        view.addConstraints([
            textField.topAnchor.constraint(equalTo: view.topAnchor),
            textField.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        textField.bind(
            .value,
            to: view,
            withKeyPath: "objectValue",
            options: nil
        )

        return view
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        songs = SongTableViewController.sort(
            songs: Set(songs),
            descriptors: tableView.sortDescriptors
        )
    }
}

// MARK: - DragDropScrollingTableViewDelegate

extension SongTableViewController: DragDropScrollingTableViewDelegate {

    func dropped(fileURLs: Set<URL>) {
        droppedFileURLHandler(fileURLs)
    }
}

// MARK: - Row actions

extension SongTableViewController {

    private var selectedIndices: IndexSet {
        var indices = tableView.selectedRowIndexes
        if indices.isEmpty {
            let clickedRow = tableView.clickedRow
            if clickedRow >= 0 {
                indices = IndexSet(integer: clickedRow)
            }
        }
        return indices
    }

    private var selectedSongs: [SongViewModel] {
        var songs = [SongViewModel]()
        let selectedIndices = selectedIndices
        selectedIndices.forEach { songs.append(self.songs[$0]) }
        return songs
    }

    @objc private func selectAllMenuItem(_ sender: AnyObject) {
        tableView.selectAll(sender)
    }

    @objc private func writeKeyToTagsMenuItem(_ sender: AnyObject) {
        songHandlers.writeToTags(selectedSongs)
    }

    @objc private func showInFinderMenuItem(_ sender: AnyObject) {
        songHandlers.showInFinder(selectedSongs)
    }

    @objc private func deleteMenuItem(_ sender: AnyObject) {
        songHandlers.deleteRows(selectedSongs)
        tableView.deselectAll(nil)
    }
}

// MARK: - Sorting

extension SongTableViewController {

    private static func sort(songs: Set<SongViewModel>, descriptors: [NSSortDescriptor]) -> [SongViewModel] {
        return songs.sorted { s1, s2 in
            for descriptor in descriptors {
                guard let rawValue = descriptor.key,
                      let columnID = Constants.SongList.ColumnID(rawValue: rawValue)
                else {
                    fatalError("something bad")
                }
                let val1 = s1.textValues[columnID.elementIndex]
                let val2 = s2.textValues[columnID.elementIndex]
                switch (val1, val2) {
                case (.none, .none):
                    return true
                case (.none, .some):
                    return descriptor.ascending
                case (.some, .none):
                    return !descriptor.ascending
                case (.some(let val1), .some(let val2)):
                    switch val1.localizedStandardCompare(val2) {
                    case .orderedSame:
                        continue
                    case .orderedAscending:
                        return descriptor.ascending
                    case .orderedDescending:
                        return !descriptor.ascending
                    }
                }
            }
            switch s1.path.localizedStandardCompare(s2.path) {
            case .orderedSame:
                return true
            case .orderedAscending:
                return true
            case .orderedDescending:
                return false
            }
        }
    }
}

// MARK: - EventHandlerDelegate

extension SongTableViewController: SongListEventHandlerDelegate {

    func selectAll() {
        selectAllMenuItem(self)
    }

    func writeKeyToTags() {
        writeKeyToTagsMenuItem(self)
    }

    func delete() {
        deleteMenuItem(self)
    }

    func showInFinder() {
        showInFinderMenuItem(self)
    }
}
