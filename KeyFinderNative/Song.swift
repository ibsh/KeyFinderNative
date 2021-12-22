//
//  Song.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

struct Song: Hashable, Equatable, Identifiable {

    enum Result: Hashable {
        case success(String)
        case failure(String)
    }

    let path: String
    let filename: String
    let artist: String?
    let title: String?
    let album: String?
    let comment: String?
    let grouping: String?
    let key: String?
    let result: Result?
    var id: String { return path }
}
