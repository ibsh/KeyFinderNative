//
//  TableViewController.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 28/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Cocoa

class TableViewController: NSViewController {

    private let writeToTags: SongHandler
    private let showInFinder: SongHandler

    private let scrollingTableView = ScrollingTableView()
    private let columns: [NSTableColumn]

    private let measuringView = NSTextView()

    private var songs: [SongViewModel] = [SongViewModel]() {
        didSet {
            let tableView = scrollingTableView.tableView
            NSLog("reloading table view")
            tableView.reloadData()
        }
    }

    // MARK: - Init

    init(
        writeToTags: @escaping SongHandler,
        showInFinder: @escaping SongHandler
    ) {
        self.writeToTags = writeToTags
        self.showInFinder = showInFinder
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
        scrollingTableView.tableView.dataSource = self
        scrollingTableView.tableView.delegate = self
        columns.forEach {
            scrollingTableView.tableView.addTableColumn($0)
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
        scrollingTableView.tableView.sortDescriptors = [
            NSSortDescriptor(
                key: Constants.ColumnID.path.rawValue,
                ascending: true
            )
        ]
    }
}

// MARK: - Interface

extension TableViewController {

    func setSongs(_ songs: Set<SongViewModel>) {
        self.songs = TableViewController.sort(
            songs: songs,
            descriptors: scrollingTableView.tableView.sortDescriptors
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
            descriptors: scrollingTableView.tableView.sortDescriptors
        )
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

private extension SongViewModel {

    var textValues: [String] {
        return TableViewController.Constants.ColumnID.allCases.map {
            switch $0 {
            case .filename: return filename
            case .path: return path
            case .title: return title ?? String()
            case .artist: return artist ?? String()
            case .album: return album ?? String()
            case .comment: return comment ?? String()
            case .grouping: return grouping ?? String()
            case .key: return key ?? String()
            case .resultString: return resultString ?? String()
            }
        }
    }
}

// MARK: - Constants

private extension TableViewController {

    enum Constants {

        enum ColumnID: String, CaseIterable {
            case path
            case filename
            case title
            case artist
            case album
            case comment
            case grouping
            case key
            case resultString

            var displayName: String {
                switch self {
                case .path: return "Path"
                case .filename: return "Filename"
                case .title: return "Title tag"
                case .artist: return "Artist tag"
                case .album: return "Album tag"
                case .comment: return "Comment tag"
                case .grouping: return "Grouping tag"
                case .key: return "Key tag"
                case .resultString: return "Detected key"
                }
            }
        }
    }
}
