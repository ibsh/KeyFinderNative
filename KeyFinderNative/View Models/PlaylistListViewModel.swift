//
//  PlaylistListViewModel.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 15/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class PlaylistListViewModel: ObservableObject {

    @Published var playlists: [PlaylistViewModel]

    init(playlists: [PlaylistViewModel] = []) {
        self.playlists = playlists
    }
}
