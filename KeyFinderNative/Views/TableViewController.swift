//
//  TableViewController.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 28/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Cocoa
import DifferenceKit

class TableViewController: NSViewController {

    private let songHandlers: SongHandlers

    private let scrollingTableView = ScrollingTableView()

    private var tableView: NSTableView {
        return scrollingTableView.tableView
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
            guard stagedChangeset.isEmpty == false else {
                print("**** No changes")
                return
            }
            let changesetText: [String] = stagedChangeset.map {
                let c = $0.changeCount
                let i = $0.elementInserted.count
                let d = $0.elementDeleted.count
                let u = $0.elementUpdated.count
                let m = $0.elementMoved.count
                return "c\(c): i\(i) d\(d) u\(u) m\(m)"
            }
            let totalChanges = stagedChangeset.reduce(0) { $0 + $1.changeCount }
            print("**** Changes (\(totalChanges) total): \(changesetText)")
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
        songHandlers: SongHandlers
    ) {
        self.songHandlers = songHandlers
        columns = Constants.ColumnID.allCases.map { columnID in
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
        tableView.dataSource = self
        tableView.delegate = self
        columns.forEach {
            tableView.addTableColumn($0)
        }
    }

    // MARK: - Overrides

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = scrollingTableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sortDescriptors = [
            NSSortDescriptor(
                key: Constants.ColumnID.path.rawValue,
                ascending: true
            )
        ]
        tableView.gridStyleMask = [
            .solidHorizontalGridLineMask,
            .solidVerticalGridLineMask,
        ]
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsMultipleSelection = true

        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(
                title: "Write detected key to tags",
                action: #selector(writeToTags(_:)),
                keyEquivalent: ""
            )
        )
        menu.addItem(
            NSMenuItem(
                title: "Show in Finder",
                action: #selector(showInFinder(_:)),
                keyEquivalent: ""
            )
        )
        menu.addItem(
            NSMenuItem(
                title: "Delete selected rows",
                action: #selector(deleteSelectedRows(_:)),
                keyEquivalent: NSString(format: "%c", NSBackspaceCharacter) as String
            )
        )
        tableView.menu = menu
    }
}

// MARK: - Interface

extension TableViewController {

    func setSongs(_ songs: Set<SongViewModel>) {
        self.songs = TableViewController.sort(
            songs: songs,
            descriptors: tableView.sortDescriptors
        )
    }
}

// MARK: - NSTableViewDataSource

extension TableViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return songs.count
    }
}

// MARK: - NSTableViewDelegate

extension TableViewController: NSTableViewDelegate {

    func tableView(
        _ tableView: NSTableView,
        objectValueFor tableColumn: NSTableColumn?,
        row: Int
    ) -> Any? {
        guard let columnIDRawValue = tableColumn?.identifier.rawValue else {
            fatalError("no column identifier")
        }
        guard let columnID = Constants.ColumnID(rawValue: columnIDRawValue) else {
            fatalError("invalid column identifier \(columnIDRawValue)")
        }
        guard row >= 0, row < songs.count else {
            fatalError("index out of range")
        }

        return songs[row].textValues[columnID.elementIndex]
    }

//    func tableView(
//        _ tableView: NSTableView,
//        shouldReorderColumn columnIndex: Int,
//        toColumn newColumnIndex: Int
//    ) -> Bool {
//        NSLog("**** shouldReorderColumn")
//        return true
//    }

//    func tableView(
//        _ tableView: NSTableView,
//        rowActionsForRow row: Int,
//        edge: NSTableView.RowActionEdge
//    ) -> [NSTableViewRowAction] {
//        NSLog("**** rowActionsForRow")
//        return []
//    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }

//    func tableViewSelectionIsChanging(_ notification: Notification) {
//        NSLog("**** tableViewSelectionIsChanging \(notification)")
//    }

//    func tableViewSelectionDidChange(_ notification: Notification) {
//        NSLog("**** tableViewSelectionDidChange \(notification)")
//    }

//    func tableViewColumnDidMove(_ notification: Notification) {
//        NSLog("**** tableViewColumnDidMove \(notification)")
//    }
//
//    func tableViewColumnDidResize(_ notification: Notification) {
//        NSLog("**** tableViewColumnDidResize \(notification)")
//    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        songs = TableViewController.sort(
            songs: Set(songs),
            descriptors: tableView.sortDescriptors
        )
    }
}

// MARK: - Row actions

private extension TableViewController {

    private var selectedIndices: IndexSet {
        var indices = tableView.selectedRowIndexes
        if indices.isEmpty {
            indices = IndexSet(integer: tableView.clickedRow)
        }
        return indices
    }

    private var selectedSongs: [SongViewModel] {
        var songs = [SongViewModel]()
        selectedIndices.forEach { songs.append(self.songs[$0]) }
        return songs
    }

    @objc func writeToTags(_ sender: AnyObject) {
        songHandlers.writeToTags(selectedSongs)
    }

    @objc func showInFinder(_ sender: AnyObject) {
        songHandlers.showInFinder(selectedSongs)
    }

    @objc func deleteSelectedRows(_ sender: AnyObject) {
        songHandlers.deleteRows(selectedSongs)
        tableView.deselectAll(nil)
    }
}

// MARK: - Sorting

private extension TableViewController {

    static func sort(songs: Set<SongViewModel>, descriptors: [NSSortDescriptor]) -> [SongViewModel] {
        return songs.sorted { s1, s2 in
            for descriptor in descriptors {
                guard let rawValue = descriptor.key,
                      let columnID = Constants.ColumnID(rawValue: rawValue)
                else {
                    fatalError("something bad")
                }
                let val1 = s1.textValues[columnID.elementIndex]
                let val2 = s2.textValues[columnID.elementIndex]
                switch val1.localizedStandardCompare(val2) {
                case .orderedSame:
                    continue
                case .orderedAscending:
                    return descriptor.ascending
                case .orderedDescending:
                    return !descriptor.ascending
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
