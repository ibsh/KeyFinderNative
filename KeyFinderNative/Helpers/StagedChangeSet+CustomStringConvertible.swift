//
//  StagedChangeSet+CustomStringConvertible.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 16/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import DifferenceKit

extension StagedChangeset: CustomStringConvertible {

    public var description: String {
        let totalChanges = reduce(0) { $0 + $1.changeCount }
        let changesText: [String] = map {
            let c = $0.changeCount
            let i = $0.elementInserted.count
            let d = $0.elementDeleted.count
            let u = $0.elementUpdated.count
            let m = $0.elementMoved.count
            return "c\(c): i\(i) d\(d) u\(u) m\(m)"
        }
        return "Changeset (\(totalChanges) total): \(changesText)"
    }
}
