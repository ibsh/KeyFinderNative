//
//  EventHandler.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 30/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

protocol SongListEventHandlerDelegate: AnyObject {

    func selectAll()
    func writeKeyToTags()
    func delete()
    func showInFinder()
}

final class SongListEventHandler {

    weak var delegate: SongListEventHandlerDelegate?

    func selectAll() {
        delegate?.selectAll()
    }

    func writeKeyToTags() {
        delegate?.writeKeyToTags()
    }

    func delete() {
        delegate?.delete()
    }

    func showInFinder() {
        delegate?.showInFinder()
    }
}
