//
//  ContentView.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 30/12/2020.
//  Copyright © 2020 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI
import AVFoundation
import Combine

struct ContentView: View {
    var body: some View {
        SongList()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct Song: Hashable, Codable, Equatable, Identifiable {
    let path: String
    let filename: String
    let bestMatch: String?
    var id: String { return path }
}

final class SongListModel: ObservableObject {

    fileprivate var urls = Set<URL>() {
        didSet {
            apply()
        }
    }

    fileprivate var matches = [String: Constants.Key]() {
        didSet {
            apply()
        }
    }

    private func apply() {
        songs = urls.sorted(by: { $0.path < $1.path}).map {
            let path = $0.path
            return Song(
                path: path,
                filename: $0.lastPathComponent,
                bestMatch: matches[path]?.description
            )
        }
    }

    @Published var songs = [Song]()
}

struct SongList: View {

    private enum Activity {
        case waiting
        case dropping
        case processing
        case tagging
    }

    @ObservedObject var model = SongListModel()
    @State private var activity = Activity.waiting

    private let typeID = "public.file-url"

    private let chromaTransform = ChromaTransform(frameRate: Constants.downsampledFrameRate)
    private let blackmanWindow = TemporalWindowFactory.window(type: .blackman, N: Constants.fftFrameSize)
    private let fourierTransformer = FourierTransformer()
    private let majorProfile = ToneProfile(profile: Constants.majorProfile)
    private let minorProfile = ToneProfile(profile: Constants.minorProfile)
    private let silenceProfile = ToneProfile(profile: [Float](repeating: 0, count: Constants.bands))

    private let processingQueue = DispatchQueue.global(qos: .userInitiated)

    var body: some View {
        VStack {
            List {
                ForEach(model.songs) { entry in
                    HStack {
                        Text(entry.filename)
                        Text(entry.bestMatch ?? String())
                            .foregroundColor(Color.red)
                    }
                }
            }
            .disabled(activity != .waiting)
            .drop(if: activity == .waiting, of: [typeID]) {
                drop(items: $0)
            }
            // TODO add onDrop?
            HStack {
                Text("Progress text")
                Button("Find keys") {
                    process()
                }
                .disabled(activity != .waiting)
            }
        }
    }

    private func drop(items: [NSItemProvider]) -> Bool {

        guard items.isEmpty == false else { return false }

        activity = .dropping

        let itemDispatchGroup = DispatchGroup()

        var urls = Set<URL>()

        for item in items {

            guard item.registeredTypeIdentifiers.contains(typeID) else {
                continue
            }

            itemDispatchGroup.enter()

            item.loadItem(forTypeIdentifier: typeID) { urlData, _ in
                defer { itemDispatchGroup.leave() }
                guard let urlData = urlData as? Data else { fatalError("No URL data") }
                let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                urls.insert(url)
            }
        }

        itemDispatchGroup.notify(queue: .main) {
            activity = .waiting
            model.urls.formUnion(urls)
        }

        return true
    }

    private func process() {

        let urlsToProcess = model
            .urls
            .filter { model.matches[$0.path] == nil }
            .sorted(by: { $0.path < $1.path})

        guard urlsToProcess.isEmpty == false else { return }

        activity = .processing

        processingQueue.async {

            DispatchQueue.concurrentPerform(iterations: urlsToProcess.count) { index in

                do {

                    let url = urlsToProcess[index]

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
                        model.matches[url.path] = bestMatch
                    }

                } catch {
                    print("ERROR: \(error)")
                    return
                }
            }

            DispatchQueue.main.async {
                activity = .waiting
            }
        }
    }
}

struct Droppable: ViewModifier {
    let condition: Bool
    let typeIDs: [String]
    let isTargeted: Binding<Bool>?
    let perform: ([NSItemProvider]) -> Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            content.onDrop(of: typeIDs, isTargeted: isTargeted, perform: perform)
        } else {
            content
        }
    }
}

extension View {
    public func drop(if condition: Bool, of typeIDs: [String], isTargeted: Binding<Bool>? = nil, perform: @escaping ([NSItemProvider]) -> Bool) -> some View {
        self.modifier(
            Droppable(
                condition: condition,
                typeIDs: typeIDs,
                isTargeted: isTargeted,
                perform: perform
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
