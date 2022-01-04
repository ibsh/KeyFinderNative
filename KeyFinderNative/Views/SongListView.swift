//
//  SongListView.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI

typealias SongHandler = ([SongViewModel]) -> Void

struct SongHandlers {
    let writeToTags: SongHandler
    let showInFinder: SongHandler
    let deleteRows: SongHandler
}

struct SongListView: View {

    @ObservedObject var model: SongListViewModel
    let songHandlers: SongHandlers
    let eventHandler: EventHandler

    var body: some View {

        WrappedTableViewController(
            songs: $model.songs,
            songHandlers: songHandlers,
            eventHandler: eventHandler
        )
    }
}

// MARK: - Text value derivation

extension SongViewModel {

    var textValues: [String?] {
        return Constants.View.ColumnID.allCases.map {
            switch $0 {
            case .filename: return filename
            case .path: return path
            case .title: return tags?.title
            case .artist: return tags?.artist
            case .album: return tags?.album
            case .comment: return tags?.comment
            case .grouping: return tags?.grouping
            case .key: return tags?.key
            case .resultString: return resultString
            }
        }
    }
}
