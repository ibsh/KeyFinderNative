//
//  PlaylistViewModel.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 15/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class PlaylistViewModel {

    enum Identifier: Hashable {
        case keyFinder
        case iTunes(id: Int)
    }

    let identifier: Identifier
    let name: String
    var urls: Set<URL>

    init(
        identifier: Identifier,
        name: String,
        urls: Set<URL>
    ) {
        self.identifier = identifier
        self.name = name
        self.urls = urls
    }
}
//
//extension PlaylistViewModel: Equatable {
//    static func == (lhs: PlaylistViewModel, rhs: PlaylistViewModel) -> Bool {
//        return lhs.identifier == rhs.identifier
//    }
//}

extension PlaylistViewModel: Identifiable {

    var id: String {
        switch identifier {
        case .keyFinder:
            return "KEYFINDER"
        case .iTunes(let id):
            return "iTunes\(id)"
        }
    }
}
