//
//  WrappedTableViewController.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 28/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

struct WrappedSongTableViewController: NSViewControllerRepresentable {

    @Binding var songs: Set<SongViewModel>
    let songHandlers: SongHandlers
    let eventHandler: SongListEventHandler

    func makeNSViewController(
        context: NSViewControllerRepresentableContext<WrappedSongTableViewController>
    ) -> SongTableViewController {
        return SongTableViewController(
            songHandlers: songHandlers,
            eventHandler: eventHandler
        )
    }

    func updateNSViewController(
        _ nsViewController: SongTableViewController,
        context: NSViewControllerRepresentableContext<WrappedSongTableViewController>
    ) {
        nsViewController.setSongs(songs)
    }
}
