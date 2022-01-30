//
//  TableView.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 28/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Cocoa

class ScrollingTableView: NSView {

    private let scrollView = NSScrollView()

    let tableView: NSTableView = {
        let tableView = NSTableView(frame: .zero)
        tableView.rowSizeStyle = .large
        tableView.backgroundColor = .clear
        return tableView
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    override init(frame frameRect: NSRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Interface

extension ScrollingTableView {

    var hasVerticalScroller: Bool {
        get {
            return scrollView.hasVerticalScroller
        }
        set {
            scrollView.hasVerticalScroller = newValue
        }
    }

    var hasHorizontalScroller: Bool {
        get {
            return scrollView.hasHorizontalScroller
        }
        set {
            scrollView.hasHorizontalScroller = newValue
        }
    }
}

// MARK: - Layout

extension ScrollingTableView {

    private func setup() {
        scrollView.documentView = tableView

        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
