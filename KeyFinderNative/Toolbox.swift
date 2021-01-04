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

    private static var _workingFormat: AVAudioFormat?

    static func workingFormatFactory() -> AVAudioFormat {
        if let workingFormat = _workingFormat {
            return workingFormat
        }
        guard let workingFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: Double(Constants.downsampledFrameRate),
            channels: 1,
            interleaved: false
        ) else {
            fatalError("Could not generate working format")
        }
        _workingFormat = workingFormat
        return workingFormat
    }

    private static var _blackmanWindow: [Float]?
    static func blackmanWindowFactory() -> [Float] {
        if let blackmanWindow = _blackmanWindow {
            return blackmanWindow
        }
        var blackmanWindow = [Float]()
        let N = Constants.fftFrameSize
        for n in 0..<N {
            let n = Float(n)
            let N = Float(N)
            let element = 0.42 - (0.5 * cos((2 * .pi * n)/(N-1))) + (0.08 * cos((4 * .pi * n)/(N-1)))
            blackmanWindow.append(element)
        }
        _blackmanWindow = blackmanWindow
        return blackmanWindow
    }

    private static var _chromaTransform: ChromaTransform?
    static func chromaTransformFactory() -> ChromaTransform {
        if let chromaTransform = _chromaTransform {
            return chromaTransform
        }
        let chromaTransform = ChromaTransform(frameRate: Constants.downsampledFrameRate)
        _chromaTransform = chromaTransform
        return chromaTransform
    }

    private static var _classifier: Classifier?
    static func classifierFactory() -> Classifier {
        if let classifier = _classifier {
            return classifier
        }
        let classifier = Classifier()
        _classifier = classifier
        return classifier
    }

    private static var _tagReader: TagReader?
    static func tagReaderFactory() -> TagReader {
        if let tagReader = _tagReader {
            return tagReader
        }
        let tagReader = TagReader()
        _tagReader = tagReader
        return tagReader
    }
}
