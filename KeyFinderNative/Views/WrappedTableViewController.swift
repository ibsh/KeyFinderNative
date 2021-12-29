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

struct WrappedTableViewController: NSViewControllerRepresentable {

    @Binding var songs: [SongViewModel]
    let writeToTags: SongHandler
    let showInFinder: SongHandler

    func makeNSViewController(
        context: NSViewControllerRepresentableContext<WrappedTableViewController>
    ) -> TableViewController {
        return TableViewController(
            writeToTags: writeToTags,
            showInFinder: showInFinder
        )
    }

    func updateNSViewController(
        _ nsViewController: TableViewController,
        context: NSViewControllerRepresentableContext<WrappedTableViewController>
    ) {
        nsViewController.setSongs(songs)
    }
}
