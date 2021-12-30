//
//  EventHandler.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 30/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

protocol EventHandlerDelegate: AnyObject {

    func selectAll()
    func writeKeyToTags()
    func delete()
    func showInFinder()
}

final class EventHandler {

    weak var delegate: EventHandlerDelegate?

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
