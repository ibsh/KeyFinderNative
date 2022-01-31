//
//  EnumElementIndex.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 28/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

extension CaseIterable where Self: Equatable {

    var elementIndex: Self.AllCases.Index {
        return Self.allCases.firstIndex(of: self)!
    }
}
