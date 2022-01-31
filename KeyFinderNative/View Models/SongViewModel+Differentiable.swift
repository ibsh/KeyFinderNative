//
//  SongViewModel+Differentiable.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 30/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import DifferenceKit

extension SongViewModel: Differentiable {

    // Identity
    var differenceIdentifier: String {
        return path
    }

    // Equality
    func isContentEqual(to source: SongViewModel) -> Bool {
        return textValues == source.textValues
    }
}
