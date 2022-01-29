//
//  WrappedPlaylistTableViewController.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 15/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

struct WrappedPlaylistTableViewController: NSViewControllerRepresentable {

    @ObservedObject var model: PlaylistListViewModel
    let playlistHandlers: PlaylistHandlers

    func makeNSViewController(
        context: NSViewControllerRepresentableContext<WrappedPlaylistTableViewController>
    ) -> PlaylistTableViewController {
        return PlaylistTableViewController(
            playlistHandlers: playlistHandlers
        )
    }

    func updateNSViewController(
        _ nsViewController: PlaylistTableViewController,
        context: NSViewControllerRepresentableContext<WrappedPlaylistTableViewController>
    ) {
        nsViewController.setPlaylists(model.playlists)
    }
}
