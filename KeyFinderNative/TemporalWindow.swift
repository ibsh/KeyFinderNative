//
//  TemporalWindow.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 01/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

enum TemporalWindowFactory {

    enum WindowType {
        case blackman
        case hamming
    }

    static func window(type: WindowType, N: Int) -> [Float] {
        var window = [Float]()
        for n in 0..<N {
            window.append(self.window(type: type, n: n, N: N))
        }
        return window
    }

    private static func window(type: WindowType, n: Int, N: Int) -> Float {
        let n = Float(n)
        let N = Float(N)
        switch type {
        case .blackman:
            return 0.42 - (0.5 * cos((2 * .pi * n)/(N-1))) + (0.08 * cos((4 * .pi * n)/(N-1)))
        case .hamming:
            return 0.54 - (0.46 * cos((2 * .pi * n)/(N-1)))
        }
    }
}
