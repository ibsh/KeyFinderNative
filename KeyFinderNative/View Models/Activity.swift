//
//  ActivityViewModel.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 29/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

enum Activity: CustomStringConvertible {
    case waiting
    case loadingPlaylists
    case loadingSongs
    case readingTags
    case processing
    case tagging

    var description: String {
        switch self {
        case .waiting:
            return String()
        case .loadingPlaylists:
            return "Reading playlists"
        case .loadingSongs:
            return "Reading file system"
        case .readingTags:
            return "Reading tags"
        case .processing:
            return "Analysing"
        case .tagging:
            return "Writing tags"
        }
    }
}

final class ActivityWrapper {

    let activity: Activity

    init(activity: Activity) {
        self.activity = activity
    }

    var isWaiting: Bool {
        switch activity {
        case .waiting:
            return true
        case .loadingPlaylists,
             .loadingSongs,
             .readingTags,
             .processing,
             .tagging:
            return false
        }
    }
}
