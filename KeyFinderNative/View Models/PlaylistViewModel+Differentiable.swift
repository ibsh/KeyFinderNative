//
//  PlaylistViewModel+Differentiable.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 15/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import DifferenceKit

extension PlaylistViewModel: Differentiable {

    // Identity
    var differenceIdentifier: String {
        return String(id)
    }

    // Equality
    func isContentEqual(to source: PlaylistViewModel) -> Bool {
        return id == id
    }
}
