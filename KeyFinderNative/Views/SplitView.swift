//
//  SplitView.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 30/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import SwiftUI

struct SplitView: NSViewControllerRepresentable {

    @ObservedObject var model: ContentViewModel
    let playlistHandlers: PlaylistHandlers
    let songHandlers: SongHandlers
    let songListEventHandler: SongListEventHandler
    let droppedFileURLHandler: DroppedFileURLHandler

    func makeNSViewController(context: Context) -> SplitViewController {
        return SplitViewController(
            playlistHandlers: playlistHandlers,
            songHandlers: songHandlers,
            songListEventHandler: songListEventHandler,
            droppedFileURLHandler: droppedFileURLHandler
        )
    }

    func updateNSViewController(_ nsViewController: SplitViewController, context: Context) {
        nsViewController.playlistTableViewController.setIsEnabled(model.activityWrapper.isWaiting)
        nsViewController.playlistTableViewController.setPlaylists(model.playlists)
        nsViewController.songTableViewController.setIsEnabled(model.activityWrapper.isWaiting)
        nsViewController.songTableViewController.setModel(model.songList)
        nsViewController.songTableViewController.setDragDropIsEnabled(
            model.activityWrapper.isWaiting
            && model.currentPlaylistIdentifier == .keyFinder
        )
    }
}
