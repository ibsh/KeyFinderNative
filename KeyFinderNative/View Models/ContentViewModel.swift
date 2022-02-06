//
//  ContentViewModel.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 16/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class ContentViewModel: ObservableObject {

    var activity: Activity {
        didSet {
            updateActivity()
        }
    }

    var playlists: [PlaylistViewModel] {
        didSet {
            updatePlaylistList()
            updateSongList()
        }
    }

    var currentPlaylistIdentifier: PlaylistViewModel.Identifier {
        didSet {
            updateSongList()
        }
    }

    var tagStores = [String: SongTagStore]() {
        didSet {
            updateSongList()
        }
    }

    var dirtyTagPaths = Set<String>()

    var results = [String: Result<Key, SongProcessingError>]() {
        didSet {
            updateSongList()
        }
    }

    init() {
        let currentPlaylist = PlaylistViewModel(
            identifier: .keyFinder,
            name: NSLocalizedString("KeyFinder drag and drop", comment: "Title of the internal drag and drop file 'playlist'."),
            urls: Set()
        )
        self.playlists = [currentPlaylist]
        self.currentPlaylistIdentifier = currentPlaylist.identifier
        self.activity = .waiting
        self.playlistList = PlaylistListViewModel(playlists: playlists)
        self.songList = SongListViewModel()
        self.activityWrapper = ActivityWrapper(activity: activity)
    }

    func playlist(identifier: PlaylistViewModel.Identifier) -> PlaylistViewModel {
        guard let playlist = playlists.first(where: { $0.identifier == identifier }) else {
            fatalError("Noooope")
        }
        return playlist
    }

    var currentPlaylist: PlaylistViewModel {
        return playlist(identifier: currentPlaylistIdentifier)
    }

    private func updateActivity() {
        activityWrapper = ActivityWrapper(activity: activity)
    }

    private func updatePlaylistList() {
        playlistList = PlaylistListViewModel(playlists: playlists)
    }

    private func updateSongList() {
        songList = SongListViewModel(
            songs: Set(
                currentPlaylist.urls.map {
                    let path = $0.path
                    return SongViewModel(
                        path: path,
                        filename: $0.lastPathComponent,
                        tagStore: tagStores[path],
                        result: result(path: path)
                    )
                }
            )
        )
    }

    private func result(path: String) -> SongViewModel.Result? {
        guard let result = results[path] else {
            return nil
        }
        switch result {
        case .success(let key):
            return .success(key.displayString(shortField: false, with: Preferences()))
        case .failure(let error):
            return .failure(error)
        }
    }

    @Published var playlistList: PlaylistListViewModel
    @Published var songList: SongListViewModel
    @Published var activityWrapper: ActivityWrapper
}
