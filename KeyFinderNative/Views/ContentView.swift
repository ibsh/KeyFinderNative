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

    private let eventHandler = EventHandler()

    var body: some View {
        ContentViewBody(eventHandler: eventHandler)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func selectAll() {
        eventHandler.selectAll()
    }

    func writeKeyToTags() {
        eventHandler.writeKeyToTags()
    }

    func delete() {
        eventHandler.delete()
    }

    func showInFinder() {
        eventHandler.showInFinder()
    }
}

struct ContentViewBody: View {

    private enum Activity: CustomStringConvertible {
        case waiting
        case dropping
        case readingTags
        case processing
        case tagging

        var description: String {
            switch self {
            case .waiting:
                return String()
            case .dropping:
                return "Reading file system"
            case .readingTags:
                return "Reading tags"
            case .processing:
                return "Analysing"
            case .tagging:
                return "Writing tags"
            }
        }
    }

    @ObservedObject var model = SongListViewModel()

    @State private var activity = Activity.waiting

    private let fileURLTypeID = "public.file-url"

    private let processingQueue = DispatchQueue.global(qos: .userInitiated)

    let eventHandler: EventHandler

    var body: some View {
        VStack {
            SongListView(
                model: self.model,
                songHandlers: SongHandlers(
                    writeToTags: writeToTags,
                    showInFinder: showInFinder,
                    deleteRows: deleteRows
                ),
                eventHandler: eventHandler
            )
                .disabled(activity != .waiting)
                .drop(if: activity == .waiting, of: [fileURLTypeID]) {
                    drop(items: $0)
                }
            HStack {
                Text(activity.description)
                Button("Find keys") {
                    process()
                }
                .disabled(activity != .waiting)
            }
            .padding()
        }
    }
}

extension ContentViewBody {

    private func drop(items: [NSItemProvider]) -> Bool {
        dispatchPrecondition(condition: .onQueue(.main))

        guard items.isEmpty == false else { return false }

        activity = .dropping

        let preferences = Preferences()
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
            readTags(urls: newModelURLs.subtracting(oldModelURLs), preferences: preferences)
        }

        return true
    }

    // TODO this is probably crap, I wrote it in no time.
    private func files(inDirectory url: URL) -> [URL] {
        dispatchPrecondition(condition: .notOnQueue(.main))

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

    private func readTags(urls: Set<URL>, preferences: Preferences) {
        dispatchPrecondition(condition: .onQueue(.main))

        guard urls.isEmpty == false else {
            activity = .waiting
            return
        }

        activity = .readingTags

        let urls = urls.sorted(by: { $0.path < $1.path })

        var tagStoresToMerge = [String: SongTagStore]()

        processingQueue.async {

            DispatchQueue.concurrentPerform(iterations: urls.count) { index in

                let url = urls[index]
                let songTags = Tagger(url: url, preferences: preferences).readTags()

                DispatchQueue.main.async {
                    tagStoresToMerge[url.path] = songTags
                    if tagStoresToMerge.count >= 20 {
                        model.tagStores.merge(tagStoresToMerge, uniquingKeysWith: { $1 })
                        tagStoresToMerge.removeAll()
                    }
                }
            }

            DispatchQueue.main.async {
                model.tagStores.merge(tagStoresToMerge, uniquingKeysWith: { $1 })
                activity = .waiting
            }
        }
    }

    private func process() {
        dispatchPrecondition(condition: .onQueue(.main))

        let urlsToProcess = model
            .urls
            .filter { model.results[$0.path] == nil }
            .sorted(by: { $0.path < $1.path })

        guard urlsToProcess.isEmpty == false else { return }

        activity = .processing

        let preferences = Preferences()
        let tagInterpreter = SongTagInterpreter(preferences: preferences)
        let workingFormat = Toolbox.workingFormat()

        processingQueue.async {

            let urlsAndTagsWithExistingMetadata = urlsToProcess
                .map { ($0, model.tagStores[$0.path]) }
                .filter {
                    guard let tagStore = $0.1 else { return false }
                    return tagInterpreter.allRelevantFieldsContainExistingMetadata(tagStore: tagStore)
                }

            let urlsWithExistingMetadata = urlsAndTagsWithExistingMetadata.map { $0.0 }

            var resultsWithExistingMetadata = [String: Result<Key, SongProcessingError>]()
            for url in urlsWithExistingMetadata {
                resultsWithExistingMetadata[url.path] = .failure(.existingMetadata)
            }

            DispatchQueue.main.async {
                model.results.merge(resultsWithExistingMetadata, uniquingKeysWith: { $1 })
            }

            let urlsToDecode = urlsToProcess.filter { !urlsWithExistingMetadata.contains($0) }

            DispatchQueue.concurrentPerform(iterations: urlsToDecode.count) { index in

                let url = urlsToProcess[index]

                let decoder = Decoder(workingFormat: workingFormat)
                let decodingResult = decoder.decode(url: url, preferences: preferences)

                let result: Result<Key, SongProcessingError>

                switch decodingResult {
                case .failure(let error):
                    result = .failure(.decoder(error))
                case .success(let samples):
                    let spectrumAnalyser = SpectrumAnalyser()
                    let classifier = Toolbox.classifier()
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
                    writeToTags(urlsToDecode, preferences: preferences)
                }
            }
        }
    }

    private func writeToTags(_ urls: [URL], preferences: Preferences) {
        dispatchPrecondition(condition: .onQueue(.main))

        guard urls.isEmpty == false else { return }

        activity = .tagging

        processingQueue.async {
            for url in urls {
                guard let result = model.results[url.path] else { continue }
                switch result {
                case .failure:
                    continue
                case .success(let key):
                    let tagger = Tagger(url: url, preferences: preferences)
                    tagger.writeTags(key: key)
                }
            }

            DispatchQueue.main.async {
                readTags(urls: Set(urls), preferences: preferences)
            }
        }
    }

    private func writeToTags(_ songs: [SongViewModel]) {
        dispatchPrecondition(condition: .onQueue(.main))

        writeToTags(
            songs.map { URL(fileURLWithPath: $0.path) },
            preferences: Preferences()
        )
    }

    private func showInFinder(_ songs: [SongViewModel]) {
        dispatchPrecondition(condition: .onQueue(.main))

        let urls = songs.map { URL(fileURLWithPath: $0.path) }
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }

    private func deleteRows(_ songs: [SongViewModel]) {
        dispatchPrecondition(condition: .onQueue(.main))

        model.songs.subtract(songs)
    }
}
