//
//  FFT.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 31/12/2020.
//  Copyright © 2020 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import Accelerate

final class FourierTransformer {

    func fourier(signal: [Float]) -> [Float] {

        let signalLength = vDSP_Length(signal.count)

        let log2n = vDSP_Length(log2(Float(signalLength)))

        guard let fftSetup = vDSP.FFT(
            log2n: log2n,
            radix: .radix2,
            ofType: DSPSplitComplex.self
        ) else {
            print("bad things")
            return []
        }

        let halfSignalLength = Int(signalLength / 2)

        var forwardInputReal = [Float](repeating: 0, count: halfSignalLength)
        var forwardInputImag = [Float](repeating: 0, count: halfSignalLength)
        var forwardOutputReal = [Float](repeating: 0, count: halfSignalLength)
        var forwardOutputImag = [Float](repeating: 0, count: halfSignalLength)

        var magnitudes = [Float](repeating: 0, count: halfSignalLength)

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
