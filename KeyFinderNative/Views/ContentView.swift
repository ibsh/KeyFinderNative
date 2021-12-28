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
        ContentViewBody()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentViewBody: View {

    private enum Activity {
        case waiting
        case dropping
        case readingTags
        case processing
        case tagging
    }

    @State private var activity = Activity.waiting
    @ObservedObject var model = SongListViewModel()

    private let fileURLTypeID = "public.file-url"

    private let processingQueue = DispatchQueue.global(qos: .userInitiated)
    private let tagReadingSemaphore = DispatchSemaphore(value: Constants.parallelTagReaders)

    var body: some View {
        VStack {
            SongListView(
                model: self.model,
                writeToTags: self.writeToTags,
                showInFinder: self.showInFinder
            )
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

        var tagsToMerge = [String: SongTags]()
        var completedCount = 0

        for url in urls.sorted(by: { $0.path < $1.path }) {
            processingQueue.async {
                tagReadingSemaphore.wait()
                let songTags = Tagger(url: url).readTags()
                DispatchQueue.main.async {
                    tagsToMerge[url.path] = songTags
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
            }

            DispatchQueue.main.async {
                activity = .waiting

                if preferences.writeAutomatically {
                    writeToTags(urlsToProcess, preferences: preferences)
                }
            }
        }
    }

    private func writeToTags(_ urls: [URL], preferences: Preferences) {

        guard urls.isEmpty == false else { return }

        activity = .tagging

        processingQueue.async {
            for url in urls {
                guard let result = model.results[url.path] else { continue }
                switch result {
                case .failure:
                    continue
                case .success(let key):
                    let tagger = Tagger(url: url)
                    tagger.writeTags(key: key, preferences: preferences)
                }
            }

            DispatchQueue.main.async {
                readTags(urls: Set(urls))
            }
        }
    }

    private func writeToTags(_ song: SongViewModel) {

        activity = .tagging

        let url = URL(fileURLWithPath: song.path)
        guard let result = model.results[url.path] else { return }

        switch result {
        case .failure:
            return
        case .success(let key):
            processingQueue.async {
                let tagger = Tagger(url: url)
                tagger.writeTags(key: key, preferences: Preferences())
                DispatchQueue.main.async {
                    readTags(urls: Set([url]))
                }
            }
        }
    }

    private func showInFinder(_ song: SongViewModel) {
        let url = URL(fileURLWithPath: song.path)
        if url.hasDirectoryPath {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
        } else {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
