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
    let eventHandler: SongListEventHandler

    var body: some View {

        WrappedSongTableViewController(
            songs: $model.songs,
            songHandlers: songHandlers,
            eventHandler: eventHandler
        )
    }
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
