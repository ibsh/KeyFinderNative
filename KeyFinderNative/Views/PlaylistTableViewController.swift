//
//  PlaylistTableViewController.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 15/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Cocoa
import DifferenceKit

final class PlaylistTableViewController: NSViewController {

    private let playlistHandlers: PlaylistHandlers

    private let scrollingTableView = ScrollingTableView()

    private var tableView: NSTableView {
        return scrollingTableView.tableView
    }

    private let measuringView = NSTextView()

    /// - Warning: do not access this directly, it is boxed by `playlists`.
    private var _playlists = [PlaylistViewModel]()
    private var playlists: [PlaylistViewModel] {
        get {
            return _playlists
        }
        set {
            let stagedChangeset = StagedChangeset(source: _playlists, target: newValue)
            guard stagedChangeset.isEmpty == false else { return }
            let selectFirstPlaylist = _playlists.isEmpty && !newValue.isEmpty
            tableView.reload(
                using: stagedChangeset,
                with: .effectFade,
                setData: { _playlists = $0 }
            )
            if selectFirstPlaylist {
                tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            }
        }
    }

    // MARK: - Init

    init(
        playlistHandlers: PlaylistHandlers
    ) {
        self.playlistHandlers = playlistHandlers
        measuringView.textContainer?.maximumNumberOfLines = 1
        super.init(nibName: nil, bundle: nil)
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

        let column = NSTableColumn(
            identifier: NSUserInterfaceItemIdentifier(
                rawValue: "PLAYLISTS"
            )
        )
        column.title = NSLocalizedString(
            "Playlists",
            comment: "Column header for playlists table"
        )

        tableView.gridStyleMask = [
            .solidHorizontalGridLineMask,
            .solidVerticalGridLineMask,
        ]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addTableColumn(column)
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsMultipleSelection = false

        scrollingTableView.hasVerticalScroller = true
        scrollingTableView.hasHorizontalScroller = false
    }
}

// MARK: - Interface

extension PlaylistTableViewController {

    func setIsEnabled(_ isEnabled: Bool) {
        tableView.isEnabled = isEnabled
    }

    func setPlaylists(_ playlists: [PlaylistViewModel]) {
        self.playlists = playlists
    }
}

// MARK: - NSTableViewDataSource

extension PlaylistTableViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return playlists.count
    }
}

// MARK: - NSTableViewDelegate

extension PlaylistTableViewController: NSTableViewDelegate {

    func tableView(
        _ tableView: NSTableView,
        objectValueFor tableColumn: NSTableColumn?,
        row: Int
    ) -> Any? {
        guard (0..<playlists.count).contains(row) else {
            fatalError("index out of range")
        }

        return playlists[row].name
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        guard (0..<playlists.count).contains(row) else { return false }
        playlistHandlers.selected(playlists[row])
        return true
    }
}
