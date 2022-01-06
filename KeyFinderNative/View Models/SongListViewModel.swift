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

    var tagStores = [String: SongTagStore]() {
        didSet {
            apply()
        }
    }

    var results = [String: Result<Key, SongProcessingError>]() {
        didSet {
            apply()
        }
    }

    private func apply() {
        songs = Set(
            urls.map {
                let path = $0.path
                return SongViewModel(
                    path: path,
                    filename: $0.lastPathComponent,
                    tagStore: tagStores[path],
                    result: result(path: path)
                )
            }
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
            return .failure(error.localizedDescription)
        }
    }

    @Published var songs = Set<SongViewModel>()
}
