//
//  InitializableWithOptional.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

protocol InitializableWithOptional {
    associatedtype T
    init?(optionalRawValue: T?)
}

extension InitializableWithOptional where Self: RawRepresentable {
    init?(optionalRawValue: RawValue?) {
        guard let rawValue = optionalRawValue else { return nil }
        self.init(rawValue: rawValue)
    }
}
