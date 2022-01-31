//
//  Tagger.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 28/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import AVFoundation

final class Tagger {

    private let wrapper: TagIOWrapping
    private let tagInterpreterFactory: SongTagInterpreterFactory
    private let preferences: Preferences

    init(
        url: URL,
        wrapperFactory: TagIOWrappingFactory = Constants.defaultTagIOWrappingFactory,
        tagInterpreterFactory: @escaping SongTagInterpreterFactory = Constants.defaultTagInterpreterFactory,
        preferences: Preferences
    ) {
        wrapper = wrapperFactory(url)
        self.tagInterpreterFactory = tagInterpreterFactory
        self.preferences = preferences
    }

    func readTags() -> SongTagStore {
        return tagStore
    }

    func writeTags(key: Key) {
        let tagStore = self.tagStore
        let tagInterpreter = tagInterpreterFactory(preferences)
        wrapper.writeTags(
            title: tagInterpreter.stringToWrite(field: .title, key: key, tagStore: tagStore),
            artist: tagInterpreter.stringToWrite(field: .artist, key: key, tagStore: tagStore),
            album: tagInterpreter.stringToWrite(field: .album, key: key, tagStore: tagStore),
            comment: tagInterpreter.stringToWrite(field: .comment, key: key, tagStore: tagStore),
            grouping: tagInterpreter.stringToWrite(field: .grouping, key: key, tagStore: tagStore),
            key: tagInterpreter.stringToWrite(field: .key, key: key, tagStore: tagStore)
        )
    }
}

extension Tagger {

    private var tagStore: SongTagStore {
        return SongTagStore(
            title: wrapper.getTitle(),
            artist: wrapper.getArtist(),
            album: wrapper.getAlbum(),
            comment: wrapper.getComment(),
            grouping: wrapper.getGrouping(),
            key: wrapper.getKey()
        )
    }
}

extension Tagger {

    private enum Constants {

        static let defaultTagIOWrappingFactory: TagIOWrappingFactory = {
            TagLibWrapper(url: $0)
        }

        static let defaultTagInterpreterFactory: SongTagInterpreterFactory = {
            SongTagInterpreter(
                preferences: $0
            )
        }
    }
}
