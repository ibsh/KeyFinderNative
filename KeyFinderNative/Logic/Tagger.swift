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

    private let wrapper: TagLibWrapper

    init(url: URL) {
        wrapper = TagLibWrapper(url: url)
    }

    func readTags() -> SongTags? {
        return tags
    }

    func writeTags(key: Constants.Key, preferences: Preferences) {
        guard let tags = tags else {
            print("Nope")
            return
        }
        wrapper.writeTags(
            withTitle: preferences.writeTo(field: .title, key: key, tags: tags),
            artist: preferences.writeTo(field: .artist, key: key, tags: tags),
            album: preferences.writeTo(field: .album, key: key, tags: tags),
            comment: preferences.writeTo(field: .comment, key: key, tags: tags),
            grouping: preferences.writeTo(field: .grouping, key: key, tags: tags),
            key: preferences.writeTo(field: .key, key: key, tags: tags)
        )
    }

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

private extension Preferences {

    func writeTo(field: SongTags.Field, key: Constants.Key, tags: SongTags) -> String? {
        let resultString = key.resultString(for: field, with: self)
        switch tags.titleFieldContainsExistingMetadata(self) {
        case .noExistingData:
            break
        case .existingData,
                .irrelevant:
            return nil
        }
        switch howToWrite(to: field) {
        case .no:
            return nil
        case .prepend:
            if let title = tags.title {
                return "\(resultString)\(fieldDelimiter)\(title)"
            } else {
                return resultString
            }
        case .append:
            if let title = tags.title {
                return "\(title)\(fieldDelimiter)\(resultString)"
            } else {
                return resultString
            }
        case .overwrite:
            return resultString
        }
    }
}

private extension Preferences.HowToWrite {

    var isPrepend: Bool {
        switch self {
        case .no, .append, .overwrite: return false
        case .prepend: return true
        }
    }

    var isAppend: Bool {
        switch self {
        case .no, .prepend, .overwrite: return false
        case .append: return true
        }
    }

    var isOverwrite: Bool {
        switch self {
        case .no, .prepend, .append: return false
        case .overwrite: return true
        }
    }
}
