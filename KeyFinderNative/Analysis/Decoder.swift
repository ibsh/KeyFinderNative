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

    enum DecoderError: Error, Equatable, Hashable, CustomStringConvertible {
        case durationExceedsPreference
        case couldNotDeriveReadBuffer
        case couldNotDeriveWorkingBuffer
        case couldNotDeriveConverter
        case couldNotDeriveChannelData
        case other(String)

        var description: String {
            switch self {
            case .durationExceedsPreference: return "File too long"
            case .couldNotDeriveReadBuffer: return "Cannot decode this file"
            case .couldNotDeriveWorkingBuffer: return "Internal error deriving working buffer"
            case .couldNotDeriveConverter: return "Internal error deriving converter"
            case .couldNotDeriveChannelData: return "Internal error decoding channel data"
            case .other(let error): return error
            }
        }
    }

    private let workingFormat: AVAudioFormat

    init(workingFormat: AVAudioFormat) {
        self.workingFormat = workingFormat
    }

    func decode(
        url: URL,
        preferences: Preferences
    ) -> Result<[Float], DecoderError> {

        print("Decoding \(url.path)")

        do {

            let file = try AVAudioFile(forReading: url)

            let processingFormat = file.processingFormat

            let duration = TimeInterval(file.length) / processingFormat.sampleRate
            let preference = TimeInterval(preferences.skipFilesLongerThanMinutes * 60)
            if duration > preference {
                print("Duration (\(duration)) exceeds preference (\(preference)) for \(url.path)")
                return .failure(.durationExceedsPreference)
            }

            let frameCapacity = AVAudioFrameCount(file.length)
            guard let fileBuffer = AVAudioPCMBuffer(
                pcmFormat: processingFormat,
                frameCapacity: frameCapacity
            ) else {
                print("Could not derive read buffer of capacity \(frameCapacity) for \(url.path)")
                return .failure(.couldNotDeriveReadBuffer)
            }

            try file.read(into: fileBuffer)

            guard let workingBuffer = AVAudioPCMBuffer(
                pcmFormat: workingFormat,
                frameCapacity: fileBuffer.frameCapacity
            ) else {
                print("Could not derive working buffer of capacity \(frameCapacity) for \(url.path)")
                return .failure(.couldNotDeriveWorkingBuffer)
            }

            guard let converter = AVAudioConverter(
                from: fileBuffer.format,
                to: workingFormat
            ) else {
                print("Could not derive working converter of format \(fileBuffer.format) for \(url.path)")
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
                let errorDescription = conversionError.localizedDescription
                print("Encountered conversion error for \(url.path): \(errorDescription)")
                return .failure(.other(errorDescription))
            }

            guard let channelData = workingBuffer.floatChannelData else {
                print("Could not derive channel data for \(url.path)")
                return .failure(.couldNotDeriveChannelData)
            }

            let bufferPointer = UnsafeBufferPointer(
                start: channelData[0],
                count: Int(workingBuffer.frameLength)
            )

            print("Successfully decoded \(url.path)")
            return .success(Array(bufferPointer))

        } catch {

            let errorDescription = error.localizedDescription
            print("Encountered unexpected error for \(url.path): \(errorDescription)")
            return .failure(.other(errorDescription))
        }
    }
}
