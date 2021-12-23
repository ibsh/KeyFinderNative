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
    private static let workingFormatLock = NSRecursiveLock()
    static func workingFormatFactory() -> AVAudioFormat {
        workingFormatLock.lock()
        defer { workingFormatLock.unlock() }
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
    private static let blackmanWindowLock = NSRecursiveLock()
    static func blackmanWindowFactory() -> [Float] {
        blackmanWindowLock.lock()
        defer { blackmanWindowLock.unlock() }
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
    private static let chromaTransformLock = NSRecursiveLock()
    static func chromaTransformFactory() -> ChromaTransform {
        chromaTransformLock.lock()
        defer { chromaTransformLock.unlock() }
        if let chromaTransform = _chromaTransform {
            return chromaTransform
        }
        let chromaTransform = ChromaTransform(frameRate: Constants.downsampledFrameRate)
        _chromaTransform = chromaTransform
        return chromaTransform
    }

    private static var _classifier: Classifier?
    private static let classifierLock = NSRecursiveLock()
    static func classifierFactory() -> Classifier {
        classifierLock.lock()
        defer { classifierLock.unlock() }
        if let classifier = _classifier {
            return classifier
        }
        let classifier = Classifier()
        _classifier = classifier
        return classifier
    }

    private static var _tagReader: TagReader?
    private static let tagReaderLock = NSRecursiveLock()
    static func tagReaderFactory() -> TagReader {
        tagReaderLock.lock()
        defer { tagReaderLock.unlock() }
        if let tagReader = _tagReader {
            return tagReader
        }
        let tagReader = TagReader()
        _tagReader = tagReader
        return tagReader
    }
}
