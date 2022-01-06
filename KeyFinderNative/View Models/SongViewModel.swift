//
//  SongViewModel.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

struct SongViewModel: Hashable, Equatable, Identifiable {

    enum Result: Hashable {
        case success(String)
        case failure(String)

        fileprivate var string: String {
            switch self {
            case .success(let string): return string
            case .failure(let string): return string
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
