//
//  SongProcessingError.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

enum SongProcessingError: Error {
    case existingMetadata
    case decoder(_: Decoder.DecoderError)
}
