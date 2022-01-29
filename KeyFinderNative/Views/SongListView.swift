//
//  SongListView.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI

typealias SongHandler = ([SongViewModel]) -> Void

struct SongHandlers {
    let writeToTags: SongHandler
    let showInFinder: SongHandler
    let deleteRows: SongHandler
}

struct SongListView: View {

    @ObservedObject var model: SongListViewModel
    let songHandlers: SongHandlers
    let songListEventHandler: SongListEventHandler

    var body: some View {

        WrappedSongTableViewController(
            model: model,
            songHandlers: songHandlers,
            songListEventHandler: songListEventHandler
        )
    }
}
