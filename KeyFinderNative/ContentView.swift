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

    var id: String { return path }
}

final class SongListModel: ObservableObject {
    @Published var songs = [Song]()
}

struct SongList: View {

    @ObservedObject var model = SongListModel()

    var body: some View {
        List {
            ForEach(model.songs) { entry in
                HStack {
                    Text(entry.filename)
                    Text(String(entry.sampleCount))
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
                            commonFormat: .pcmFormatInt16,
                            sampleRate: 2056,
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

                        guard let channelData = workingBuffer.int16ChannelData else {
                            print("no channel data for \(url)")
                            return
                        }
                        let bufferPointer = UnsafeBufferPointer(
                            start: channelData[0],
                            count: Int(workingBuffer.frameLength)
                        )
                        let samples = Array(bufferPointer)

                        DispatchQueue.main.async {
                            model.songs.append(
                                Song(
                                    path: url.path,
                                    filename: url.lastPathComponent,
                                    sampleCount: samples.count
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
