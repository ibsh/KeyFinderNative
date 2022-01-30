//
//  SplitThings.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 29/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import AppKit

final class SplitViewController: NSSplitViewController {

    let playlistTableViewController: PlaylistTableViewController
    let songTableViewController: SongTableViewController

    init(
        playlistHandlers: PlaylistHandlers,
        songHandlers: SongHandlers,
        songListEventHandler: SongListEventHandler,
        droppedFileURLHandler: @escaping DroppedFileURLHandler
    ) {
        playlistTableViewController = PlaylistTableViewController(
            playlistHandlers: playlistHandlers
        )
        songTableViewController = SongTableViewController(
            songHandlers: songHandlers,
            songListEventHandler: songListEventHandler,
            droppedFileURLHandler: droppedFileURLHandler
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        splitView.dividerStyle = .paneSplitter
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: Constants.SplitView.restorationID)
        playlistTableViewController.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        songTableViewController.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 400).isActive = true
        let playlists = NSSplitViewItem(viewController: playlistTableViewController)
        playlists.canCollapse = true
        addSplitViewItem(playlists)
        addSplitViewItem(NSSplitViewItem(viewController: songTableViewController))
        // gotta set this after adding views, strangely
        splitView.autosaveName = NSSplitView.AutosaveName(Constants.SplitView.restorationID)
    }
}
