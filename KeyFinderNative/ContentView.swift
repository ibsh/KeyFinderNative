//
//  ContentView.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 30/12/2020.
//  Copyright © 2020 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        SongList()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct Song: Hashable, Codable, Equatable, Identifiable {
    let path: String
    let filename: String
    let sampleCount: Int
    let chromaVector: [Float]
    let bestMatch: String

    var id: String { return path }
}

final class SongListModel: ObservableObject {
    @Published var songs = [Song]()
}

struct SongList: View {

    @ObservedObject var model = SongListModel()

    private let chromaTransform = ChromaTransform(frameRate: Constants.downsampledFrameRate)
    private let blackmanWindow = TemporalWindowFactory.window(type: .blackman, N: Constants.fftFrameSize)
    private let fourierTransformer = FourierTransformer()
    private let majorProfile = ToneProfile(profile: Constants.majorProfile)
    private let minorProfile = ToneProfile(profile: Constants.minorProfile)
    private let silenceProfile = ToneProfile(profile: [Float](repeating: 0, count: Constants.bands))

    var body: some View {
        List {
            ForEach(model.songs) { entry in
                HStack {
                    Text(entry.filename)
                    Text(String(entry.sampleCount))
                    Text(entry.bestMatch)
                }
            }
        }
        .onDrop(of: ["public.file-url"], isTargeted: nil) { (items) -> Bool in
            guard items.isEmpty == false else { return false }
            for item in items {
                guard item.registeredTypeIdentifiers.contains("public.file-url") else { continue }
                item.loadItem(forTypeIdentifier: "public.file-url") { urlData, _ in
                    guard let urlData = urlData as? Data else {
                        print("bad things")
                        return
                    }
                    let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                    do {

                        let file = try AVAudioFile(forReading: url)

                        guard let fileBuffer = AVAudioPCMBuffer(
                            pcmFormat: file.processingFormat,
                            frameCapacity: AVAudioFrameCount(file.length)
                        ) else {
                            print("No file buffer for \(url)")
                            return
                        }
                        try file.read(into: fileBuffer)

                        guard let workingFormat = AVAudioFormat(
                            commonFormat: .pcmFormatFloat32,
                            sampleRate: Double(Constants.downsampledFrameRate),
                            channels: 1,
                            interleaved: false
                        ) else {
                            print("No working format for \(url)")
                            return
                        }

                        guard let workingBuffer = AVAudioPCMBuffer(
                            pcmFormat: workingFormat,
                            frameCapacity: fileBuffer.frameCapacity
                        ) else {
                            print("No working buffer for \(url)")
                            return
                        }

                        guard let converter = AVAudioConverter(
                            from: fileBuffer.format,
                            to: workingBuffer.format
                        ) else {
                            print("No converter for \(url)")
                            return
                        }

                        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                            outStatus.pointee = AVAudioConverterInputStatus.haveData
                            return fileBuffer
                        }

                        var conversionError: NSError?

                        converter.convert(to: workingBuffer, error: &conversionError, withInputFrom: inputBlock)

                        if let conversionError = conversionError {
                            print("ERROR for \(url): \(conversionError)")
                            return
                        }

                        guard let channelData = workingBuffer.floatChannelData else {
                            print("no channel data for \(url)")
                            return
                        }
                        let bufferPointer = UnsafeBufferPointer(
                            start: channelData[0],
                            count: Int(workingBuffer.frameLength)
                        )
                        let samples = Array(bufferPointer)

                        let fftFrameSize = Constants.fftFrameSize
                        var windowStart = 0
                        var chromagram = [[Float]]()

                        while windowStart + fftFrameSize < samples.count {
                            var localSamples = [Float]()
                            for index in 0..<fftFrameSize {
                                localSamples.append(samples[windowStart + index] * blackmanWindow[index])
                            }
                            let magnitudes = fourierTransformer.fourier(signal: localSamples)
                            let chromaVector = chromaTransform.chromaVector(magnitudes: magnitudes)
                            chromagram.append(chromaVector)
                            windowStart += Constants.hopSize
                        }

                        if windowStart < samples.count {
                            var localSamples = [Float](repeating: 0, count: fftFrameSize)
                            for offsetIndex in windowStart..<samples.count {
                                let index = offsetIndex % fftFrameSize
                                localSamples[index] = samples[offsetIndex] * blackmanWindow[index]
                            }
                            let magnitudes = fourierTransformer.fourier(signal: localSamples)
                            let chromaVector = chromaTransform.chromaVector(magnitudes: magnitudes)
                            chromagram.append(chromaVector)
                        }

                        var chromaVector = [Float](repeating: 0, count: Constants.bands)
                        let hops = Float(chromagram.count)
                        for hop in chromagram {
                            for band in 0..<Constants.bands {
                                chromaVector[band] += hop[band] / hops
                            }
                        }

                        var scores = [Float](repeating: 0, count: Constants.semitones * 2)
                        for i in 0..<Constants.semitones {
                            scores[i*2] = majorProfile.cosineSimilarity(input: chromaVector, offset: i)
                            scores[(i*2)+1] = minorProfile.cosineSimilarity(input: chromaVector, offset: i)
                        }
                        var bestScore: Float = silenceProfile.cosineSimilarity(input: chromaVector, offset: 0)
                        var bestMatch = Constants.Key.silence
                        for (i, score) in scores.enumerated() where score > bestScore {
                            bestScore = score
                            bestMatch = Constants.Key.allCases[i]
                        }

                        DispatchQueue.main.async {
                            model.songs.append(
                                Song(
                                    path: url.path,
                                    filename: url.lastPathComponent,
                                    sampleCount: samples.count,
                                    chromaVector: chromaVector,
                                    bestMatch: bestMatch.description
                                )
                            )
                        }
                    } catch {
                        print("ERROR: \(error)")
                        return
                    }
                }
            }
            return true
        }
//        .onDrag {
//            let data = self.image?.tiffRepresentation
//            let provider = NSItemProvider(item: data as NSSecureCoding?, typeIdentifier: kUTTypeTIFF as String)
//            provider.previewImageHandler = { (handler, _, _) -> Void in
//                handler?(data as NSSecureCoding?, nil)
//            }
//            return provider
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
