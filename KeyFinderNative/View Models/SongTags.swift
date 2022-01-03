//
//  SongTags.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

struct SongTags {
    let title: String?
    let artist: String?
    let album: String?
    let comment: String?
    let grouping: String?
    let key: String?
}

extension SongTags {

    func hasExistingMetadata(preferences: Preferences) -> Bool {
        let valuesToCheck = valuesToCheck(preferences)
        return tagsToCheck(preferences)
            .compactMap { (howToWrite, value, isKeyTag) in
                switch (howToWrite, value) {
                case (.no, _):
                    return nil
                case (.prepend, .some(let value)):
                    let result = valuesToCheck.first(where: { value.hasPrefix($0) })
                    return result != nil
                case (.append, .some(let value)):
                    let result = valuesToCheck.first(where: { value.hasSuffix($0) })
                    return result != nil
                case (.overwrite, .some(let value)):
                    let result = valuesToCheck
                        .map { isKeyTag ? String($0.prefix(3)) : $0 }
                        .first(where: { value == $0 })
                    return result != nil
                case (_, .none):
                    return false
                }
            }
            .allSatisfy { $0 }
    }
}

private extension SongTags {

    func tagsToCheck(_ preferences: Preferences) -> [(Preferences.HowToWrite, String?, Bool)] {
        var results = [(Preferences.HowToWrite, String?, Bool)]()
        results.append((preferences.howToWriteToTitleTag, title, false))
        results.append((preferences.howToWriteToArtistTag, artist, false))
        results.append((preferences.howToWriteToAlbumTag, album, false))
        results.append((preferences.howToWriteToCommentTag, comment, false))
        results.append((preferences.howToWriteToGroupingTag, grouping, false))
        results.append((preferences.howToWriteToKeyTag, key, true))
        return results
    }

    func valuesToCheck(_ preferences: Preferences) -> [String] {
        return Constants.Key.allCases.compactMap { key in
            if key == .silence { return nil }
            return key.resultString(preferences: preferences)
        }
    }
}
