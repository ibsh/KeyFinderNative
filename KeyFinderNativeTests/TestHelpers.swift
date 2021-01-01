//
//  TestHelpers.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 31/12/2020.
//  Copyright © 2020 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

func sine(
    index: Int,
    frequency: Float,
    sampleRate: Int,
    magnitude: Int
) -> Float {
    return Float(magnitude) * sin(Float(index) * frequency / Float(sampleRate) * 2 * Float.pi)
}
