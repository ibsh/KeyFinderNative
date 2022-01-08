//
//  SongTagStore.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

struct SongTagStore: Hashable, Equatable {
    let title: String?
    let artist: String?
    let album: String?
    let comment: String?
    let grouping: String?
    let key: String?
}

extension SongTagStore {

    func value(for field: SongTagField) -> String? {
        switch field {
        case .title:    return title
        case .artist:   return artist
        case .album:    return album
        case .comment:  return comment
        case .grouping: return grouping
        case .key:      return key
        }
    }
}
