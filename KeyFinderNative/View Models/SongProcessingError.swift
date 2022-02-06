//
//  SongProcessingError.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

enum SongProcessingError: Error, Equatable, Hashable {
    case existingMetadata
    case decoder(_: Decoder.DecoderError)
}

extension SongProcessingError: CustomStringConvertible {

    var description: String {
        switch self {
        case .existingMetadata:
            return NSLocalizedString("Skipped file with existing metadata", comment: "File analysis status message")
        case .decoder(let decoderError):
            return decoderError.description
        }
    }
}
