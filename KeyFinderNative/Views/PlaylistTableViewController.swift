//
//  PlaylistTableViewController.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 15/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Cocoa
import DifferenceKit

class PlaylistTableViewController: NSViewController {

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
            let threshold = _playlists.count / 2
            tableView.reload(
                using: stagedChangeset,
                with: .effectFade,
                interrupt: { $0.changeCount > threshold },
                setData: { _playlists = $0 }
            )
        }
    }

    // MARK: - Init

    init(
        playlistHandlers: PlaylistHandlers
    ) {
        self.playlistHandlers = playlistHandlers
        let column = NSTableColumn(
            identifier: NSUserInterfaceItemIdentifier(
                rawValue: "PLAYLISTS"
            )
        )
        column.title = "Playlists"
        measuringView.textContainer?.maximumNumberOfLines = 1
        super.init(nibName: nil, bundle: nil)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addTableColumn(column)
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
        tableView.gridStyleMask = [
            .solidHorizontalGridLineMask,
            .solidVerticalGridLineMask,
        ]
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsMultipleSelection = false
    }
}

// MARK: - Interface

extension PlaylistTableViewController {

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
        guard row >= 0, row < playlists.count else {
            fatalError("index out of range")
        }

        return playlists[row].name
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
}
