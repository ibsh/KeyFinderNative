//
//  Bridging.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 30/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

typealias PlaylistHandler = (PlaylistViewModel) -> Void

struct PlaylistHandlers {
    let selected: PlaylistHandler
}

typealias SongHandler = ([SongViewModel]) -> Void

struct SongHandlers {
    let writeToTags: SongHandler
    let showInFinder: SongHandler
    let deleteRows: SongHandler
}

typealias DroppedFileURLHandler = (Set<URL>) -> Void
