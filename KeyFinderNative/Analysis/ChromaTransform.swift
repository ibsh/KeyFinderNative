//
//  ChromaTransform.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 01/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class ChromaTransform {

    private let chromaBandFftBinIndices: [Int]
    private let kernel: [[Float]]

    init(frameRate: Int) {

        let frameRate = Float(frameRate)

        if Constants.Analysis.frequencies.last! > frameRate / 2.0 {
            fatalError("Analysis frequencies over Nyquist")
        }

        let fftFrameSize = Float(Constants.Analysis.fftFrameSize)

        if frameRate / fftFrameSize > (Constants.Analysis.frequencies[1] - Constants.Analysis.frequencies[0]) {
            fatalError("Insufficient low-end resolution")
        }

        var chromaBandFftBinIndices = [Int]()
        var kernel = [[Float]]()

        let myQFactor = Constants.Analysis.directSKStretch * (pow(2, (1.0 / Float(Constants.Analysis.semitones))) - 1)

        for i in (0..<Constants.Analysis.bands) {

            let centreOfWindow = Constants.Analysis.frequencies[i] * fftFrameSize / frameRate
            let widthOfWindow = centreOfWindow * myQFactor
            let beginningOfWindow = centreOfWindow - (widthOfWindow / 2)
            let endOfWindow = beginningOfWindow + widthOfWindow

            var sumOfCoefficients: Float = 0.0
            var kernelEntry = [Float]()

            let firstUsefulBinIndex = Int(ceil(beginningOfWindow))
            chromaBandFftBinIndices.append(firstUsefulBinIndex)
            for fftBin in firstUsefulBinIndex..<Int(floor(endOfWindow)) {
                let coefficient = ChromaTransform.kernelWindow(n: Float(fftBin) - beginningOfWindow, N: widthOfWindow)
                sumOfCoefficients += coefficient
                kernelEntry.append(coefficient)
            }

            // normalisation by sum of coefficients and frequency of bin; models CQT very closely
            for j in 0..<kernelEntry.count {
                kernelEntry[j] = kernelEntry[j] / sumOfCoefficients * Constants.Analysis.frequencies[i]
            }
            kernel.append(kernelEntry)
        }

        self.chromaBandFftBinIndices = chromaBandFftBinIndices
        self.kernel = kernel
    }

    private static func kernelWindow(n: Float, N: Float) -> Float {
        // discretely sampled continuous function, but different to other window functions
        return 1.0 - cos((2 * .pi * n) / N)
    }

    func chromaVector(magnitudes: [Float]) -> [Float] {
        var chromaVector = [Float]()
        for i in 0..<Constants.Analysis.bands {
            var sum: Float = 0.0
            for j in 0..<kernel[i].count {
                let magnitude = magnitudes[chromaBandFftBinIndices[i] + j]
                sum += magnitude * kernel[i][j]
            }
            chromaVector.append(sum)
        }
        return chromaVector
    }
}
