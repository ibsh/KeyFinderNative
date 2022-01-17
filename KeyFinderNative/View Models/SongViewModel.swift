//
//  SongViewModel.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import AppKit

struct SongViewModel: Equatable, Hashable, Identifiable {

    enum Result: Equatable, Hashable {
        case success(String)
        case failure(SongProcessingError)

        fileprivate var string: String {
            switch self {
            case .success(let string): return string
            case .failure(let error): return error.description
            }
        }
    }

    let path: String

    let filename: String
    let tagStore: SongTagStore?
    let result: Result?

    var resultString: String? { return result?.string }

    var id: String { return path }
}

// MARK: - Text value derivation

extension SongViewModel {

    var textValues: [String?] {
        return Constants.SongList.ColumnID.allCases.map {
            switch $0 {
            case .filename: return filename
            case .path: return path
            case .title: return tagStore?.title
            case .artist: return tagStore?.artist
            case .album: return tagStore?.album
            case .comment: return tagStore?.comment
            case .grouping: return tagStore?.grouping
            case .key: return tagStore?.key
            case .resultString: return resultString
            }
        }
    }
}
