//
//  Droppable.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 09/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import SwiftUI

struct Droppable: ViewModifier {
    let condition: Bool
    let typeIDs: [String]
    let isTargeted: Binding<Bool>?
    let perform: ([NSItemProvider]) -> Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            content.onDrop(of: typeIDs, isTargeted: isTargeted, perform: perform)
        } else {
            content
        }
    }
}

extension View {
    public func drop(
        if condition: Bool,
        of typeIDs: [String],
        isTargeted: Binding<Bool>? = nil,
        perform: @escaping ([NSItemProvider]) -> Bool
    ) -> some View {
        self.modifier(
            Droppable(
                condition: condition,
                typeIDs: typeIDs,
                isTargeted: isTargeted,
                perform: perform
            )
        )
    }
}
