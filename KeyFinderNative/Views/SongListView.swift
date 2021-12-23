//
//  SongListView.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI

struct SongListView: View {

    @ObservedObject var model = SongListViewModel()

    var body: some View {
        List {
            HeaderRow()
                .modifier(RowSpacingStyle())
            ForEach(model.songs) { song in
                SongRow(song: song)
                    .modifier(RowSpacingStyle())
            }
        }
    }
}
