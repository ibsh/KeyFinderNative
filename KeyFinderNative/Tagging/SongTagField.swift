//
//  SongTagField.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 05/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

enum SongTagField: CaseIterable {
    case title
    case artist
    case album
    case comment
    case grouping
    case key
}

extension SongTagField {

    var isShort: Bool {
        switch self {
        case .title,
                .artist,
                .album,
                .comment,
                .grouping:
            return false
        case .key:
            return true
        }
    }
}
