//
//  TagIOWrapping.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

protocol TagIOWrapping {

    func getTitle() -> String?
    func getArtist() -> String?
    func getAlbum() -> String?
    func getComment() -> String?
    func getGrouping() -> String?
    func getKey() -> String?

    func writeTags(
        title: String?,
        artist: String?,
        album: String?,
        comment: String?,
        grouping: String?,
        key: String?
    )
}

extension TagLibWrapper: TagIOWrapping { }

typealias TagIOWrappingFactory = (URL) -> TagIOWrapping
