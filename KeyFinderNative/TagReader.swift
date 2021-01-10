//
//  TagReader.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 02/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import AVFoundation

struct Tag {
    let title: String?
    let artist: String?
    let album: String?
    let comment: String?
    let grouping: String?
    let key: String?
}

final class TagReader {

    func readTag(url: URL, completion: @escaping (Tag?) -> Void) {
        let asset = AVURLAsset(url: url)
        let formatsKey = "availableMetadataFormats"
        asset.loadValuesAsynchronously(forKeys: [formatsKey]) {
            var error: NSError?
            let status = asset.statusOfValue(forKey: formatsKey, error: &error)
            if status == .loaded {

                var title: String?
                var artist: String?
                var album: String?
                var comment: String?
                var grouping: String?
                var key: String?

                for format in asset.availableMetadataFormats {
                    for item in asset.metadata(forFormat: format) {
                        switch item.identifier?.rawValue.lowercased() {
                        case "id3/tit2",
                             "itsk/%A9nam":
                            title = item.stringValue
                        case "id3/tpe1",
                             "itsk/%a9art":
                            artist = item.stringValue
                        case "id3/talb",
                             "itsk/%a9alb":
                            album = item.stringValue
                        case "id3/comm",
                             "itsk/%a9cmt":
                            comment = item.stringValue
                        case "id3/tit1",
                             "itsk/%a9grp":
                            grouping = item.stringValue
                        case "id3/tkey",
                             "itlk/com.apple.itunes.initialkey":
                            key = item.stringValue
                        default:
                            break
                        }
                    }
                }

                let tag = Tag(
                    title: title,
                    artist: artist,
                    album: album,
                    comment: comment,
                    grouping: grouping,
                    key: key
                )

                completion(tag)
            } else {
                completion(nil)
            }
        }
    }
}
