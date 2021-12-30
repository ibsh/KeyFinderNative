//
//  ModalWindow.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 30/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Cocoa

final class ModalWindow: NSWindow {

    override func becomeKey() {
        super.becomeKey()
        level = .statusBar
    }

    override func close() {
        super.close()
        NSApp.stopModal()
    }
}
