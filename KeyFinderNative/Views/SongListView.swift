//
//  SongListView.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI

struct SongListView: View {

    @ObservedObject var model: SongListViewModel
    let writeToTags: SongHandler
    let showInFinder: SongHandler

    var body: some View {

        WrappedTableViewController(
            songs: $model.songs,
            writeToTags: writeToTags,
            showInFinder: showInFinder
        )
    }
}
