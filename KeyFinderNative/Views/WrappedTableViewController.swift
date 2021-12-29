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

    @Binding var songs: Set<SongViewModel>
    let songHandlers: SongHandlers

    func makeNSViewController(
        context: NSViewControllerRepresentableContext<WrappedTableViewController>
    ) -> TableViewController {
        return TableViewController(
            songHandlers: songHandlers
        )
    }

    func updateNSViewController(
        _ nsViewController: TableViewController,
        context: NSViewControllerRepresentableContext<WrappedTableViewController>
    ) {
        nsViewController.setSongs(songs)
    }
}
