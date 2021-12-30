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

    var textValues: [String] {
        return Constants.ColumnID.allCases.map {
            switch $0 {
            case .filename: return filename
            case .path: return path
            case .title: return title ?? String()
            case .artist: return artist ?? String()
            case .album: return album ?? String()
            case .comment: return comment ?? String()
            case .grouping: return grouping ?? String()
            case .key: return key ?? String()
            case .resultString: return resultString ?? String()
            }
        }
    }
}
