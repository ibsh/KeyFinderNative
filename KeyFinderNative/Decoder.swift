//
//  Decoder.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 02/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import AVFoundation

final class Decoder {

    enum DecoderError: Error, CustomStringConvertible {
        case couldNotDeriveReadBuffer
        case couldNotDeriveWorkingBuffer
        case couldNotDeriveConverter
        case couldNotDeriveChannelData
        case other(Error)

        var description: String {
            switch self {
            case .couldNotDeriveReadBuffer: return "Cannot decode this file"
            case .couldNotDeriveWorkingBuffer: return "Internal error deriving working buffer"
            case .couldNotDeriveConverter: return "Internal error deriving converter"
            case .couldNotDeriveChannelData: return "Internal error decoding channel data"
            case .other(let error): return error.localizedDescription
            }
        }
    }

    private let workingFormat: AVAudioFormat

    init(workingFormat: AVAudioFormat) {
        self.workingFormat = workingFormat
    }

    convenience init() {
        self.init(workingFormat: Toolbox.workingFormatFactory())
    }

    func decode(url: URL) -> Result<[Float], DecoderError> {

        do {

            let file = try AVAudioFile(forReading: url)

            guard let fileBuffer = AVAudioPCMBuffer(
                pcmFormat: file.processingFormat,
                frameCapacity: AVAudioFrameCount(file.length)
            ) else {
                return .failure(.couldNotDeriveReadBuffer)
            }

            try file.read(into: fileBuffer)

            guard let workingBuffer = AVAudioPCMBuffer(
                pcmFormat: workingFormat,
                frameCapacity: fileBuffer.frameCapacity
            ) else {
                return .failure(.couldNotDeriveWorkingBuffer)
            }

            guard let converter = AVAudioConverter(
                from: fileBuffer.format,
                to: workingFormat
            ) else {
                return .failure(.couldNotDeriveConverter)
            }

            let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                outStatus.pointee = AVAudioConverterInputStatus.haveData
                return fileBuffer
            }

            var conversionError: NSError?

            converter.convert(
                to: workingBuffer,
                error: &conversionError,
                withInputFrom: inputBlock
            )

            if let conversionError = conversionError {
                return .failure(.other(conversionError))
            }

            guard let channelData = workingBuffer.floatChannelData else {
                return .failure(.couldNotDeriveChannelData)
            }

            let bufferPointer = UnsafeBufferPointer(
                start: channelData[0],
                count: Int(workingBuffer.frameLength)
            )

            return .success(Array(bufferPointer))

        } catch {

            return .failure(.other(error))
        }
    }
}
