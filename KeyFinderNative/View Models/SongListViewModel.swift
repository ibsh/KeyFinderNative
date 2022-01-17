//
//  SongListViewModel.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class SongListViewModel: ObservableObject {

    @Published var songs: Set<SongViewModel>

    init(songs: Set<SongViewModel> = Set()) {
        self.songs = songs
    }
}
