//
//  PlaylistViewModel.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 15/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

struct PlaylistViewModel: Hashable, Equatable, Identifiable {

    enum Kind: Hashable {
        case keyFinder
        case iTunes(id: Int)
    }

    let kind: Kind
    let name: String

    var id: String {
        switch kind {
        case .keyFinder:
            return "KEYFINDER"
        case .iTunes(let id):
            return "iTunes\(id)"
        }
    }
}
