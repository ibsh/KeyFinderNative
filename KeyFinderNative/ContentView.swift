//
//  ContentView.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 30/12/2020.
//  Copyright © 2020 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        SongListView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SongListView: View {

    private enum Activity {
        case waiting
        case dropping
        case readingTags
        case processing
        case tagging
    }

    @ObservedObject var model = SongListViewModel()
    @State private var activity = Activity.waiting

    private let fileURLTypeID = "public.file-url"

    private let processingQueue = DispatchQueue.global(qos: .userInitiated)
    private let tagReadingSemaphore = DispatchSemaphore(value: Constants.parallelTagReaders)

    var body: some View {
        VStack {
            List {
                HeaderRow()
                    .modifier(RowSpacingStyle())
                ForEach(model.songs) { song in
                    SongRow(song: song)
                        .modifier(RowSpacingStyle())
                }
            }
            .disabled(activity != .waiting)
            .drop(if: activity == .waiting, of: [fileURLTypeID]) {
                drop(items: $0)
            }
            // TODO add onDrag?
            HStack {
                Text("Progress text")
                Button("Find keys") {
                    process()
                }
                .disabled(activity != .waiting)
            }
            .padding()
        }
    }

    private func drop(items: [NSItemProvider]) -> Bool {

        guard items.isEmpty == false else { return false }

        activity = .dropping

        let itemDispatchGroup = DispatchGroup()

        var urls = Set<URL>()

        for item in items {

            guard item.registeredTypeIdentifiers.contains(fileURLTypeID) else {
                continue
            }

            itemDispatchGroup.enter()

            item.loadItem(forTypeIdentifier: fileURLTypeID) { urlData, _ in
                defer { itemDispatchGroup.leave() }
                guard let urlData = urlData as? Data else { fatalError("No URL data") }
                let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                let subURLs = files(inDirectory: url)
                urls.formUnion(subURLs)
            }
        }

        itemDispatchGroup.notify(queue: .main) {
            let oldModelURLs = model.urls
            let newModelURLs = oldModelURLs.union(urls)
            model.urls = newModelURLs
            readTags(urls: newModelURLs.subtracting(oldModelURLs))
        }

        return true
    }

    private func readTags(urls: Set<URL>) {
        guard urls.isEmpty == false else {
            activity = .waiting
            return
        }

        activity = .readingTags

        let totalCount = urls.count

        var tagsToMerge = [String: Tag]()
        var completedCount = 0

        for url in urls.sorted(by: { $0.path < $1.path }) {
            processingQueue.async {
                tagReadingSemaphore.wait()
                Toolbox.tagReaderFactory().readTag(url: url) { tag in
                    DispatchQueue.main.async {
                        tagsToMerge[url.path] = tag
                        completedCount += 1
                        if tagsToMerge.count >= 20 {
                            model.tags.merge(tagsToMerge, uniquingKeysWith: { $1 })
                            tagsToMerge.removeAll()
                        }
                        if completedCount >= totalCount {
                            model.tags.merge(tagsToMerge, uniquingKeysWith: { $1 })
                            activity = .waiting
                        }
                        tagReadingSemaphore.signal()
                    }
                }
            }
        }
    }

    // TODO this is probably crap, I wrote it in no time.
    private func files(inDirectory url: URL) -> [URL] {
        let keys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .isDirectoryKey,
        ]
        var files = [URL]()
        do {
            let attributes = try url.resourceValues(forKeys: keys)
            if attributes.isRegularFile == .some(true) {
                files.append(url)
            } else if attributes.isDirectory == .some(true) {
                guard let enumerator = FileManager.default.enumerator(
                    at: url,
                    includingPropertiesForKeys: Array(keys),
                    options: [.skipsHiddenFiles, .skipsPackageDescendants]
                ) else {
                    return []
                }
                for case let enumeratedURL as URL in enumerator {
                    files.append(contentsOf: self.files(inDirectory: enumeratedURL))
                }
            }
        } catch {
            print(error)
        }
        return files
    }

    private func process() {

        let urlsToProcess = model
            .urls
            .filter { model.results[$0.path] == nil }
            .sorted(by: { $0.path < $1.path })

        guard urlsToProcess.isEmpty == false else { return }

        activity = .processing

        let preferences = Preferences()

        processingQueue.async {

            DispatchQueue.concurrentPerform(iterations: urlsToProcess.count) { index in

                let url = urlsToProcess[index]

                let decoder = Decoder()
                let decodingResult = decoder.decode(url: url)

                var result: Result<Constants.Key, Decoder.DecoderError>

                switch decodingResult {
                case .failure(let error):
                    result = .failure(error)
                case .success(let samples):
                    let spectrumAnalyser = SpectrumAnalyser()
                    let classifier = Toolbox.classifierFactory()
                    let chromaVector = spectrumAnalyser.chromaVector(samples: samples)
                    let key = classifier.classify(chromaVector: chromaVector)
                    result = .success(key)
                }

                DispatchQueue.main.async {
                    model.results[url.path] = result
                }

                if preferences.writeAutomatically {
                    // TODO write process
                }
            }

            DispatchQueue.main.async {
                activity = .waiting
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
