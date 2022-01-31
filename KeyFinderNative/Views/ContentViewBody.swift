//
//  ContentViewBody.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 23/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI
import iTunesLibrary

struct ContentViewBody: View {

    @ObservedObject private var model = ContentViewModel()

    private let processingQueue = DispatchQueue.global(qos: .userInitiated)

    let songListEventHandler: SongListEventHandler

    var body: some View {
        VStack {
            SplitView(
                model: model,
                playlistHandlers: PlaylistHandlers(
                    selected: selectPlaylist
                ),
                songHandlers: SongHandlers(
                    writeToTags: writeToTags,
                    showInFinder: showInFinder,
                    deleteRows: deleteRows
                ),
                songListEventHandler: songListEventHandler,
                droppedFileURLHandler: droppedFileURLs
            )
                .disabled(!model.activityWrapper.isWaiting)
            HStack {
                Text(model.activityWrapper.activity.description)
                Button("Find keys") {
                    process()
                }
                .disabled(!model.activityWrapper.isWaiting)
            }
            .padding()
        }
        .onAppear {
            loadiTunesPlaylists()
        }
    }
}

extension ContentViewBody {

    private func droppedFileURLs(_ droppedFileURLs: Set<URL>) {
        dispatchPrecondition(condition: .onQueue(.main))

        guard model.currentPlaylistIdentifier == .keyFinder else {
            fatalError("Nooope")
        }

        guard droppedFileURLs.isEmpty == false else { return }

        model.activity = .loadingSongs

        let preferences = Preferences()
        let itemDispatchGroup = DispatchGroup()

        var songURLs = Set<URL>()

        processingQueue.async {

            for droppedFileURL in droppedFileURLs {
                itemDispatchGroup.enter()
                defer { itemDispatchGroup.leave() }
                let subURLs = files(inDirectory: droppedFileURL)
                songURLs.formUnion(subURLs)
            }

            itemDispatchGroup.notify(queue: .main) {
                let playlist = model.playlist(identifier: .keyFinder)
                playlist.urls.formUnion(songURLs)
                readTags(preferences: preferences)
            }
        }
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

    private func readTags(
        preferences: Preferences
    ) {
        dispatchPrecondition(condition: .onQueue(.main))

        let playlistURLs = model.currentPlaylist.urls
        let tagStoreURLs = Set(model.tagStores.keys.map { URL(fileURLWithPath: $0) })
        let dirtyTagStoreURLs = Set(model.dirtyTagPaths.map { URL(fileURLWithPath: $0) })
        let cleanTagStoreURLs = tagStoreURLs.subtracting(dirtyTagStoreURLs)

        let urls = playlistURLs
            .subtracting(cleanTagStoreURLs)
            .sorted(by: { $0.path < $1.path })

        guard urls.isEmpty == false else {
            model.activity = .waiting
            return
        }

        model.activity = .readingTags

        var tagStoresToMerge = [String: SongTagStore]()

        processingQueue.async {

            DispatchQueue.concurrentPerform(iterations: urls.count) { index in

                let url = urls[index]
                let songTags = Tagger(url: url, preferences: preferences).readTags()

                DispatchQueue.main.async {
                    tagStoresToMerge[url.path] = songTags
                    if tagStoresToMerge.count >= 20 {
                        model.tagStores.merge(tagStoresToMerge, uniquingKeysWith: { $1 })
                        model.dirtyTagPaths.formIntersection(Set(tagStoresToMerge.keys))
                        tagStoresToMerge.removeAll()
                    }
                }
            }

            DispatchQueue.main.async {
                model.tagStores.merge(tagStoresToMerge, uniquingKeysWith: { $1 })
                model.dirtyTagPaths.formIntersection(Set(tagStoresToMerge.keys))
                model.activity = .waiting
            }
        }
    }

    private func process() {
        dispatchPrecondition(condition: .onQueue(.main))

        let urlsToProcess = model
            .currentPlaylist
            .urls
            .filter {
                switch model.results[$0.path] {
                case .none:
                    return true
                case .success:
                    return false
                case .failure(let error):
                    switch error {
                    case .existingMetadata:
                        return true
                    case .decoder:
                        return false
                    }
                }
            }
            .sorted(by: { $0.path < $1.path })

        guard urlsToProcess.isEmpty == false else {
            print("Nothing to process")
            return
        }

        model.activity = .processing

        let preferences = Preferences()
        let tagInterpreter = SongTagInterpreter(preferences: preferences)
        let workingFormat = Toolbox.workingFormat()

        processingQueue.async {

            let urlsToDecode: [URL]

            if preferences.skipFilesWithExistingMetadata {

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
                urlsToDecode = urlsToProcess.filter { !urlsWithExistingMetadata.contains($0) }

            } else {
                urlsToDecode = urlsToProcess
            }

            print("Processing \(urlsToDecode.count) files")

            DispatchQueue.concurrentPerform(iterations: urlsToDecode.count) { index in

                let url = urlsToProcess[index]

                let decoder = Decoder(workingFormat: workingFormat)
                let decodingResult = decoder.decode(url: url, preferences: preferences)

                let result: Result<Key, SongProcessingError>

                switch decodingResult {
                case .failure(let error):
                    result = .failure(.decoder(error))
                case .success(let samples):
                    print("Analysing \(url.path)")
                    let spectrumAnalyser = SpectrumAnalyser()
                    let classifier = Toolbox.classifier()
                    let chromaVector = spectrumAnalyser.chromaVector(samples: samples)
                    let key = classifier.classify(chromaVector: chromaVector)
                    print("Classified \(url.path): \(key)")
                    result = .success(key)
                }

                DispatchQueue.main.async {
                    model.results[url.path] = result
                }
            }

            DispatchQueue.main.async {
                model.activity = .waiting

                if preferences.writeAutomatically {
                    writeToTags(urlsToDecode, preferences: preferences)
                } else {
                    print("Finished processing \(urlsToDecode.count) files")
                }
            }
        }
    }

    private func writeToTags(_ urls: [URL], preferences: Preferences) {
        dispatchPrecondition(condition: .onQueue(.main))

        guard urls.isEmpty == false else {
            print("Nothing to tag")
            return
        }

        print("Tagging \(urls.count) files")

        model.activity = .tagging

        processingQueue.async {

            var dirtyTagPaths = Set<String>()
            for url in urls {
                guard let result = model.results[url.path] else { continue }
                switch result {
                case .failure:
                    continue
                case .success(let key):
                    dirtyTagPaths.insert(url.path)
                    let tagger = Tagger(url: url, preferences: preferences)
                    tagger.writeTags(key: key)
                }
            }

            print("Wrote to \(dirtyTagPaths.count) files")

            DispatchQueue.main.async {
                model.dirtyTagPaths.formUnion(dirtyTagPaths)
                readTags(preferences: preferences)
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
        guard model.currentPlaylistIdentifier == .keyFinder,
              let playlist = model.playlists.first(where: { $0.identifier == .keyFinder }) else { return }
        playlist.urls.subtract(songs.map { URL(fileURLWithPath: $0.path) })
    }

    private func selectPlaylist(_ playlist: PlaylistViewModel) {
        model.currentPlaylistIdentifier = playlist.identifier
        readTags(preferences: Preferences())
    }

    private func loadiTunesPlaylists() {
        model.activity = .loadingPlaylists
        processingQueue.async {
            guard let iTunesLibrary = try? ITLibrary(apiVersion: "1.0") else { return }
            let iTunesPlaylists = iTunesLibrary
                .allPlaylists
                .filter {
                    if #available(macOS 12.0, *) {
                        // TODO I'm guessing that this is the Library, but god knows
                        if $0.isPrimary {
                            return false
                        }
                    } else {
                        if $0.isMaster {
                            return false
                        }
                    }
                    switch $0.distinguishedKind {
                    case .kindNone:
                        return true
                    case .kindMusic,
                            .kindMovies,
                            .kindTVShows,
                            .kindAudiobooks,
                            .kindBooks,
                            .kindRingtones,
                            .kindPodcasts,
                            .kindVoiceMemos,
                            .kindPurchases,
                            .kindiTunesU,
                            .kind90sMusic,
                            .kindMyTopRated,
                            .kindTop25MostPlayed,
                            .kindRecentlyPlayed,
                            .kindRecentlyAdded,
                            .kindMusicVideos,
                            .kindClassicalMusic,
                            .kindLibraryMusicVideos,
                            .kindHomeVideos,
                            .kindApplications,
                            .kindLovedSongs,
                            .kindMusicShowsAndMovies:
                        return false
                    @unknown default:
                        return false
                    }
                }
                .map {
                    PlaylistViewModel(
                        identifier: .iTunes(id: $0.persistentID.intValue),
                        name: $0.name,
                        urls: Set($0.items.compactMap { $0.location })
                    )
                }
            DispatchQueue.main.async {
                model.playlists.append(contentsOf: iTunesPlaylists)
                model.activity = .waiting
            }
        }
    }
}
