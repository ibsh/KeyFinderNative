//
//  SpectrumAnalyser.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 02/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class SpectrumAnalyser {

    private let wrappedFourierTransform = Toolbox.fourierTransform()
    private let chromaTransform = Toolbox.chromaTransform()
    private let blackmanWindow = Toolbox.blackmanWindow()

    func chromaVector(samples: [Float]) -> [Float] {

        let fftFrameSize = Constants.Analysis.fftFrameSize
        var windowStart = 0
        var chromagram = [[Float]]()

        while windowStart < samples.count {
            let localSamples: [Float] = {
                if windowStart + fftFrameSize < samples.count {
                    var localSamples = [Float]()
                    for index in 0..<fftFrameSize {
                        localSamples.append(samples[windowStart + index] * blackmanWindow[index])
                    }
                    return localSamples
                } else {
                    var localSamples = [Float](repeating: 0, count: fftFrameSize)
                    for offsetIndex in windowStart..<samples.count {
                        let index = offsetIndex % fftFrameSize
                        localSamples[index] = samples[offsetIndex] * blackmanWindow[index]
                    }
                    return localSamples
                }
            }()
            let magnitudes = wrappedFourierTransform.wrapped.resource.fourier(signal: localSamples)
            let chromaVector = chromaTransform.chromaVector(magnitudes: magnitudes)
            chromagram.append(chromaVector)
            windowStart += Constants.Analysis.hopSize
        }

        var chromaVector = [Float](repeating: 0, count: Constants.Analysis.bands)
        let hops = Float(chromagram.count)
        for hop in chromagram {
            for band in 0..<Constants.Analysis.bands {
                chromaVector[band] += hop[band] / hops
            }
        }

        return chromaVector
    }
}
