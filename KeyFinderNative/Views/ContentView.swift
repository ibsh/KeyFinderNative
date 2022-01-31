//
//  ContentView.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 30/12/2020.
//  Copyright © 2020 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    private let songListEventHandler = SongListEventHandler()

    var body: some View {
        ContentViewBody(songListEventHandler: songListEventHandler)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func selectAll() {
        songListEventHandler.selectAll()
    }

    func writeKeyToTags() {
        songListEventHandler.writeKeyToTags()
    }

    func delete() {
        songListEventHandler.delete()
    }

    func showInFinder() {
        songListEventHandler.showInFinder()
    }
}
