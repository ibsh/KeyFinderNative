//
//  FakeTagIOWrapper.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
@testable import KeyFinder

final class FakeTagIOWrapper: TagIOWrapping {

    var titleValue: String?
    var artistValue: String?
    var albumValue: String?
    var commentValue: String?
    var groupingValue: String?
    var keyValue: String?

    func getTitle() -> String? {
        return titleValue
    }

    func getArtist() -> String? {
        return artistValue
    }

    func getAlbum() -> String? {
        return albumValue
    }

    func getComment() -> String? {
        return commentValue
    }

    func getGrouping() -> String? {
        return groupingValue
    }

    func getKey() -> String? {
        return keyValue
    }

    func writeTags(
        title: String?,
        artist: String?,
        album: String?,
        comment: String?,
        grouping: String?,
        key: String?
    ) {
        if let title = title {
            self.titleValue = title
        }
        if let artist = artist {
            self.artistValue = artist
        }
        if let album = album {
            self.albumValue = album
        }
        if let comment = comment {
            self.commentValue = comment
        }
        if let grouping = grouping {
            self.groupingValue = grouping
        }
        if let key = key {
            self.keyValue = key
        }
    }
}
