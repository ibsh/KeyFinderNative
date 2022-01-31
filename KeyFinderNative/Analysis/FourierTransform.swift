//
//  FFT.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 31/12/2020.
//  Copyright © 2020 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import Accelerate

final class FourierTransform {

    let frameSize: Int
    private let halfN: Int
    private let fftSetup: vDSP.FFT<DSPSplitComplex>

    private var forwardInputReal: [Float]
    private var forwardInputImag: [Float]
    private var forwardOutputReal: [Float]
    private var forwardOutputImag: [Float]
    private var magnitudes: [Float]

    init(frameSize: Int) {
        self.frameSize = frameSize
        halfN = frameSize / 2
        guard let fftSetup = vDSP.FFT(
            log2n: vDSP_Length(log2(Float(frameSize))),
            radix: .radix2,
            ofType: DSPSplitComplex.self
        ) else {
            fatalError("Could not build FFT setup")
        }
        self.fftSetup = fftSetup

        forwardInputReal = [Float](repeating: 0, count: halfN)
        forwardInputImag = [Float](repeating: 0, count: halfN)
        forwardOutputReal = [Float](repeating: 0, count: halfN)
        forwardOutputImag = [Float](repeating: 0, count: halfN)
        magnitudes = [Float](repeating: 0, count: halfN)
    }

    func fourier(signal: [Float]) -> [Float] {

        guard signal.count == frameSize else {
            fatalError("Invalid signal length")
        }

        forwardInputReal.withUnsafeMutableBufferPointer { forwardInputRealPtr in
            forwardInputImag.withUnsafeMutableBufferPointer { forwardInputImagPtr in
                forwardOutputReal.withUnsafeMutableBufferPointer { forwardOutputRealPtr in
                    forwardOutputImag.withUnsafeMutableBufferPointer { forwardOutputImagPtr in

                        var forwardInput = DSPSplitComplex(
                            realp: forwardInputRealPtr.baseAddress!,
                            imagp: forwardInputImagPtr.baseAddress!
                        )

                        var forwardOutput = DSPSplitComplex(
                            realp: forwardOutputRealPtr.baseAddress!,
                            imagp: forwardOutputImagPtr.baseAddress!
                        )

                        // Convert the real values in `signal` to complex numbers.
                        signal.withUnsafeBytes {
                            vDSP.convert(
                                interleavedComplexVector: [DSPComplex]($0.bindMemory(to: DSPComplex.self)),
                                toSplitComplexVector: &forwardInput
                            )
                        }

                        fftSetup.forward(
                            input: forwardInput,
                            output: &forwardOutput
                        )

                        vDSP.absolute(
                            forwardOutput,
                            result: &magnitudes
                        )
                    }
                }
            }
        }

        return magnitudes
    }
}
