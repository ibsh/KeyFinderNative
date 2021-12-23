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
        let formatsKey = Constants.TagIDs.urlAssetKey
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
                        case Constants.TagIDs.id3.title,
                             Constants.TagIDs.iTunes.title:
                            title = item.stringValue
                        case Constants.TagIDs.id3.artist,
                             Constants.TagIDs.iTunes.artist:
                            artist = item.stringValue
                        case Constants.TagIDs.id3.album,
                             Constants.TagIDs.iTunes.album:
                            album = item.stringValue
                        case Constants.TagIDs.id3.comment,
                             Constants.TagIDs.iTunes.comment:
                            comment = item.stringValue
                        case Constants.TagIDs.id3.grouping,
                             Constants.TagIDs.iTunes.grouping:
                            grouping = item.stringValue
                        case Constants.TagIDs.id3.key,
                             Constants.TagIDs.iTunes.key:
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
