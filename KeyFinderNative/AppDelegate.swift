//
//  AppDelegate.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 30/12/2020.
//  Copyright © 2020 Ibrahim Sha'ath. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var prefsWindow: NSWindow!
    var contentView: ContentView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        window = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 800,
                height: 500
            ),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .fullSizeContentView,
            ],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.setFrameAutosaveName("Main Window")

        contentView = ContentView()
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.styleMask.remove(.closable)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

// MARK: - Preferences window

extension AppDelegate {

    @IBAction func openPrefsWindow(_ sender: NSMenuItem) {
        prefsWindow = ModalWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
            styleMask: [
                .titled,
                .closable,
                .fullSizeContentView,
            ],
            backing: .buffered,
            defer: false
        )
        let prefsView = PreferencesView(window: prefsWindow)
        prefsWindow.title = "Preferences"
        prefsWindow.center()
        prefsWindow.setFrameAutosaveName("Preferences Window")
        prefsWindow.contentView = NSHostingView(rootView: prefsView)
        _ = NSApp.runModal(for: prefsWindow)
    }
}

// MARK: - Edit menu

extension AppDelegate {

    @IBAction func selectAll(_ sender: NSMenuItem) {
        contentView.selectAll()
    }

    @IBAction func writeKeyToTags(_ sender: NSMenuItem) {
        contentView.writeKeyToTags()
    }

    @IBAction func delete(_ sender: NSMenuItem) {
        contentView.delete()
    }

    @IBAction func showInFinder(_ sender: NSMenuItem) {
        contentView.showInFinder()
    }
}
