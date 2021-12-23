//
//  SongListViewModel.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class SongListViewModel: ObservableObject {

    var urls = Set<URL>() {
        didSet {
            apply()
        }
    }

    var tags = [String: Tag]() {
        didSet {
            apply()
        }
    }

    var results = [String: Result<Constants.Key, Decoder.DecoderError>]() {
        didSet {
            apply()
        }
    }

    private func apply() {
        songs = urls.sorted(by: { $0.path < $1.path}).map {
            let path = $0.path
            let tag: Tag? = tags[path]
            return SongViewModel(
                path: path,
                filename: $0.lastPathComponent,
                artist: tag?.artist,
                title: tag?.title,
                album: tag?.album,
                comment: tag?.comment,
                grouping: tag?.grouping,
                key: tag?.key,
                result: result(path: path)
            )
        }
    }

    private func result(path: String) -> SongViewModel.Result? {
        guard let result = results[path] else {
            return nil
        }
        switch result {
        case .success(let key):
            return .success(key.displayString(preferences: Preferences()))
        case .failure(let error):
            return .failure(error.localizedDescription)
        }
    }

    @Published var songs = [SongViewModel]()
}
