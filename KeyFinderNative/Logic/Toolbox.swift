//
//  Toolbox.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 02/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import AVFoundation

enum Toolbox {

    private static let workingFormatSingleton = Singleton<AVAudioFormat>(
        factory: {
            guard let workingFormat = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: Double(Constants.downsampledFrameRate),
                channels: 1,
                interleaved: false
            ) else {
                fatalError("Could not generate working format")
            }
            return workingFormat
        }
    )
    static func workingFormat() -> AVAudioFormat {
        workingFormatSingleton.get()
    }

    private static let blackmanWindowSingleton = Singleton<[Float]>(
        factory: {
            var blackmanWindow = [Float]()
            let N = Constants.fftFrameSize
            return (0..<N).map { n in
                let n = Float(n)
                let N = Float(N)
                return 0.42 - (0.5 * cos((2 * .pi * n)/(N-1))) + (0.08 * cos((4 * .pi * n)/(N-1)))
            }
        }
    )
    static func blackmanWindow() -> [Float] {
        return blackmanWindowSingleton.get()
    }

    private static let chromaTransformSingleton = Singleton<ChromaTransform>(
        factory: { return ChromaTransform(frameRate: Constants.downsampledFrameRate) }
    )
    static func chromaTransform() -> ChromaTransform {
        return chromaTransformSingleton.get()
    }

    private static let classifierSingleton = Singleton<Classifier>(
        factory: { return Classifier() }
    )
    static func classifier() -> Classifier {
        return classifierSingleton.get()
    }

    private static let fourierTransformPool = ResourcePool<FourierTransform>(
        factory: {
            FourierTransform(frameSize: Constants.fftFrameSize)
        }
    )
    static func fourierTransform() -> PooledResourceWrapper<FourierTransform> {
        return fourierTransformPool.get()
    }
}
