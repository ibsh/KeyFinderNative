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
            return NSLocalizedString("Reading playlists", comment: "Application status string")
        case .loadingSongs:
            return NSLocalizedString("Reading file system", comment: "Application status string")
        case .readingTags:
            return NSLocalizedString("Reading tags", comment: "Application status string")
        case .processing:
            return NSLocalizedString("Analysing", comment: "Application status string")
        case .tagging:
            return NSLocalizedString("Writing tags", comment: "Application status string")
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
