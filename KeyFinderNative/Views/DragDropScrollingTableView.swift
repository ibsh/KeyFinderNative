//
//  DragDropScrollingTableView.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 29/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Cocoa

protocol DragDropScrollingTableViewDelegate: AnyObject {
    func dropped(fileURLs: Set<URL>)
}

class DragDropScrollingTableView: ScrollingTableView {

    weak var delegate: DragDropScrollingTableViewDelegate?

    private var dragDropIsEnabled = false

    override init() {
        super.init()
        tableView.registerForDraggedTypes([.fileURL])
    }

    func setDragDropIsEnabled(_ dragDropIsEnabled: Bool) {
        self.dragDropIsEnabled = dragDropIsEnabled
    }
}

// MARK: - Drag and drop

extension DragDropScrollingTableView {

    private var operation: NSDragOperation {
        if dragDropIsEnabled {
            return .copy
        } else {
            return []
        }
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return operation
    }

    override func wantsPeriodicDraggingUpdates() -> Bool {
        return false
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        var droppedFileURLs = Set<URL>()
        sender.enumerateDraggingItems(
            options: [],
            for: nil,
            classes: [NSURL.self],
            searchOptions: [.urlReadingFileURLsOnly: true]) { draggingItem, _, _ in
                guard let url = draggingItem.item as? URL else {
                    print("Bad dragging item")
                    return
                }
                droppedFileURLs.insert(url)
            }
        delegate?.dropped(fileURLs: droppedFileURLs)
        return true
    }
}
