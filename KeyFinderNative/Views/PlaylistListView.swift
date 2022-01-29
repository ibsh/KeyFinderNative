//
//  PlaylistListView.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 15/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI

typealias PlaylistHandler = (PlaylistViewModel) -> Void

struct PlaylistHandlers {
    let selected: PlaylistHandler
}

struct PlaylistListView: View {

    @ObservedObject var model: PlaylistListViewModel
    let playlistHandlers: PlaylistHandlers

    var body: some View {

        WrappedPlaylistTableViewController(
            model: model,
            playlistHandlers: playlistHandlers
        )
    }
}
