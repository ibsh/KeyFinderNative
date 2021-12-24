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
//        if #available(macOS 12, *) {
//            Table(model.songs) {
//                TableColumn("Filename") { Text($0.filename) }
//                TableColumn("Title tag") { Text($0.title) }
//                TableColumn("Artist tag") { Text($0.artist) }
//                TableColumn("Album tag") { Text($0.album) }
//                TableColumn("Comment tag") { Text($0.comment) }
//                TableColumn("Grouping tag") { Text($0.grouping) }
//                TableColumn("Key tag") { Text($0.key) }
//                TableColumn("Detected key") {
//                    switch $0.result {
//                    case .none:
//                        Text(String())
//                    case .success(let result):
//                        Text(result)
//                    case .failure(let result):
//                        Text(result)
//                    }
//                }
//            }
//        } else {
            List {
                HeaderRow()
                    .modifier(RowSpacingStyle())
                ForEach(model.songs) { song in
                    SongRow(
                        song: song,
                        writeToTags: writeToTags,
                        showInFinder: showInFinder
                    )
                        .modifier(RowSpacingStyle())
                }
            }
//        }
    }
}
