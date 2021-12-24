//
//  TagWriter.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class TagWriter {

    private let url: URL
    private let key: Constants.Key

    init(url: URL, key: Constants.Key) {
        self.url = url
        self.key = key
    }

    func writeTags(preferences: Preferences) {
        let wrapper = TagLibWrapper(url: url)
        wrapper.writeTags(
            withResultString: key.resultString(preferences: preferences),
            prependToTitle: preferences.prependToTitle,
            appendToTitle: preferences.appendToTitle,
            prependToArtist: preferences.prependToArtist,
            appendToArtist: preferences.appendToArtist,
            prependToAlbum: preferences.prependToAlbum,
            appendToAlbum: preferences.appendToAlbum,
            prependToComment: preferences.prependToComment,
            appendToComment: preferences.appendToComment,
            overwriteComment: preferences.overwriteComment,
            prependToGrouping: preferences.prependToGrouping,
            appendToGrouping: preferences.appendToGrouping,
            overwriteGrouping: preferences.overwriteGrouping,
            overwriteKey: preferences.overwriteKey,
            tagDelimiter: preferences.tagDelimiter
        )
    }
}

private extension Preferences {

    // MARK: - Title

    var prependToTitle: Bool {
        return howToWriteToTitleTag.isPrepend
    }

    var appendToTitle: Bool {
        return howToWriteToTitleTag.isAppend
    }

    // MARK: - Artist

    var prependToArtist: Bool {
        return howToWriteToArtistTag.isPrepend
    }

    var appendToArtist: Bool {
        return howToWriteToArtistTag.isAppend
    }

    // MARK: - Album

    var prependToAlbum: Bool {
        return howToWriteToAlbumTag.isPrepend
    }

    var appendToAlbum: Bool {
        return howToWriteToAlbumTag.isAppend
    }

    // MARK: - Comment

    var prependToComment: Bool {
        return howToWriteToCommentTag.isPrepend
    }

    var appendToComment: Bool {
        return howToWriteToCommentTag.isAppend
    }

    var overwriteComment: Bool {
        return howToWriteToCommentTag.isOverwrite
    }

    // MARK: - Grouping

    var prependToGrouping: Bool {
        return howToWriteToGroupingTag.isPrepend
    }

    var appendToGrouping: Bool {
        return howToWriteToGroupingTag.isAppend
    }

    var overwriteGrouping: Bool {
        return howToWriteToGroupingTag.isOverwrite
    }

    // MARK: - Key

    var overwriteKey: Bool {
        return howToWriteToKeyTag.isOverwrite
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
