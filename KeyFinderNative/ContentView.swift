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
        SongList()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct Song: Hashable, Codable, Equatable, Identifiable {
    let path: String
    let filename: String
    let result: String?
    var id: String { return path }
}

final class SongListModel: ObservableObject {

    fileprivate var urls = Set<URL>() {
        didSet {
            apply()
        }
    }

    fileprivate var results = [String: Result<Constants.Key, Decoder.DecoderError>]() {
        didSet {
            apply()
        }
    }

    private func apply() {
        songs = urls.sorted(by: { $0.path < $1.path}).map {
            let path = $0.path
            let result: String? = {
                guard let result = results[path] else { return nil }
                switch result {
                case .success(let key):
                    return key.description
                case .failure(let error):
                    return error.description
                }
            }()
            return Song(
                path: path,
                filename: $0.lastPathComponent,
                result: result
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

    private let fileURLTypeID = "public.file-url"

    private let processingQueue = DispatchQueue.global(qos: .userInitiated)

    var body: some View {
        VStack {
            List {
                ForEach(model.songs) { entry in
                    HStack {
                        Text(entry.filename)
                        Text(entry.result ?? String())
                            .foregroundColor(Color.red)
                    }
                }
            }
            .disabled(activity != .waiting)
            .drop(if: activity == .waiting, of: [fileURLTypeID]) {
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
            activity = .waiting
            model.urls.formUnion(urls)
        }

        return true
    }

    // TODO this is crap, I wrote it in no time.
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
            .sorted(by: { $0.path < $1.path})

        guard urlsToProcess.isEmpty == false else { return }

        activity = .processing

        processingQueue.async {

            DispatchQueue.concurrentPerform(iterations: urlsToProcess.count) { index in

                let url = urlsToProcess[index]

                let decoder = Decoder()
                let decodingResult = decoder.decode(url: url)

                switch decodingResult {
                case .failure(let error):
                    DispatchQueue.main.async {
                        model.results[url.path] = .failure(error)
                    }
                case .success(let samples):

                    let spectrumAnalyser = SpectrumAnalyser()
                    let classifier = Toolbox.classifierFactory()
                    let chromaVector = spectrumAnalyser.chromaVector(samples: samples)
                    let key = classifier.classify(chromaVector: chromaVector)

                    DispatchQueue.main.async {
                        model.results[url.path] = .success(key)
                    }
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
