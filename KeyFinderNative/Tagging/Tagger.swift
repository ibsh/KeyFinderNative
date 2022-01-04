//
//  Tagger.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 28/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import AVFoundation

final class Tagger {

    private let wrapper: TagIOWrapping
    private let preferences: Preferences

    init(
        url: URL,
        wrapperFactory: TagIOWrappingFactory = { TagLibWrapper(url: $0) },
        preferences: Preferences
    ) {
        wrapper = wrapperFactory(url)
        self.preferences = preferences
    }

    func readTags() -> SongTags? {
        return tags
    }

    func writeTags(key: Key) {
        guard let tags = tags else {
            print("Nope")
            return
        }
        wrapper.writeTags(
            title: tags.stringToWrite(field: .title, key: key, with: preferences),
            artist: tags.stringToWrite(field: .artist, key: key, with: preferences),
            album: tags.stringToWrite(field: .album, key: key, with: preferences),
            comment: tags.stringToWrite(field: .comment, key: key, with: preferences),
            grouping: tags.stringToWrite(field: .grouping, key: key, with: preferences),
            key: tags.stringToWrite(field: .key, key: key, with: preferences)
        )
    }
}

extension Tagger {

    private var tags: SongTags? {
        return SongTags(
            title: wrapper.getTitle(),
            artist: wrapper.getArtist(),
            album: wrapper.getAlbum(),
            comment: wrapper.getComment(),
            grouping: wrapper.getGrouping(),
            key: wrapper.getKey()
        )
    }
}
