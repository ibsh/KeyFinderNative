//
//  KeyFinderNativeTests.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 30/12/2020.
//  Copyright © 2020 Ibrahim Sha'ath. All rights reserved.
//

import XCTest
@testable import KeyFinderNative

class FourierTransformerTests: XCTestCase {

    func testFourierTransform() {

        let frameSize = 4096
        var original = [Float](repeating: 0, count: frameSize)

        for i in 0..<frameSize {
            var sample: Float = 0.0
            sample += sine(index: i, frequency: 2, sampleRate: frameSize, magnitude: 10000)
            sample += sine(index: i, frequency: 4, sampleRate: frameSize, magnitude: 8000)
            sample += sine(index: i, frequency: 5, sampleRate: frameSize, magnitude: 6000)
            sample += sine(index: i, frequency: 7, sampleRate: frameSize, magnitude: 4000)
            sample += sine(index: i, frequency: 13, sampleRate: frameSize, magnitude: 2000)
            sample += sine(index: i, frequency: 20, sampleRate: frameSize, magnitude: 500)
            original[i] = sample
//            let formatted = String(format: "%.2f", sample)
//            print("SIN \(i): \(formatted)")
        }

        let transformer = FourierTransformer()

        let transformed = transformer.fourier(signal: original)

        XCTAssertEqual(transformed.count, frameSize / 2)

        let accuracy: Float = 5.5

        for i in 0..<transformed.count {

            let out = transformed[i] / 2 // why is magnitude doubled versus FFTW?
            switch i {
            case 2:
                XCTAssertEqual(out, 10000 / 2 * Float(frameSize), accuracy: accuracy)
            case 4:
                XCTAssertEqual(out, 8000 / 2 * Float(frameSize), accuracy: accuracy)
            case 5:
                XCTAssertEqual(out, 6000 / 2 * Float(frameSize), accuracy: accuracy)
            case 7:
                XCTAssertEqual(out, 4000 / 2 * Float(frameSize), accuracy: accuracy)
            case 13:
                XCTAssertEqual(out, 2000 / 2 * Float(frameSize), accuracy: accuracy)
            case 20:
                XCTAssertEqual(out, 500 / 2 * Float(frameSize), accuracy: accuracy)
            default:
                XCTAssertLessThan(out, accuracy)
            }
        }
    }
}