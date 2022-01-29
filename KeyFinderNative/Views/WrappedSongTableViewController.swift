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

    @ObservedObject var model: SongListViewModel
    let songHandlers: SongHandlers
    let songListEventHandler: SongListEventHandler

    func makeNSViewController(
        context: NSViewControllerRepresentableContext<WrappedSongTableViewController>
    ) -> SongTableViewController {
        return SongTableViewController(
            songHandlers: songHandlers,
            songListEventHandler: songListEventHandler
        )
    }

    func updateNSViewController(
        _ nsViewController: SongTableViewController,
        context: NSViewControllerRepresentableContext<WrappedSongTableViewController>
    ) {
        nsViewController.setModel(model)
    }
}
