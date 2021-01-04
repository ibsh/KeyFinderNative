//
//  TagReader.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 02/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import AVFoundation

final class TagReader {

    func readTag(url: URL, completion: @escaping (Tag?) -> Void) {
        let asset = AVURLAsset(url: url)
        let formatsKey = "availableMetadataFormats"
        asset.loadValuesAsynchronously(forKeys: [formatsKey]) {
            var error: NSError?
            let status = asset.statusOfValue(forKey: formatsKey, error: &error)
            if status == .loaded {
                var artist: String?
                var title: String?
                var comment: String?
                for format in asset.availableMetadataFormats {
                    for item in asset.metadata(forFormat: format) {
                        switch item.identifier?.rawValue {
                        case "id3/TPE1",
                             "itsk/%A9ART":
                            artist = item.stringValue
                        case "id3/TIT2",
                             "itsk/%A9nam":
                            title = item.stringValue
                        case "id3/COMM",
                             "itsk/%A9cmt":
                            comment = item.stringValue
                        default:
                            break
                        }
                    }
                }
                let tag = Tag(
                    artist: artist,
                    title: title,
                    comment: comment
                )
                completion(tag)
            } else {
                completion(nil)
            }
        }
    }
}
