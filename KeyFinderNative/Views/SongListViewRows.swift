//
//  ViewModifiers.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 09/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
import SwiftUI

private let cellSpacing: CGFloat = 4

struct HeaderCells: View {
    var body: some View {
        Text("Filename").modifier(HeaderCellStyle())
        Text("Title tag").modifier(HeaderCellStyle())
        Text("Artist tag").modifier(HeaderCellStyle())
        Text("Album tag").modifier(HeaderCellStyle())
        Text("Comment tag").modifier(HeaderCellStyle())
        Text("Grouping tag").modifier(HeaderCellStyle())
        Text("Key tag").modifier(HeaderCellStyle())
        Text("Detected key").modifier(HeaderCellStyle())
    }
}

struct HeaderRow: View {
    var body: some View {
        HStack(spacing: cellSpacing) {
            HeaderCells()
        }
    }
}

struct SongCells: View {

    @State var song: SongViewModel

    var body: some View {
        Text(song.filename).modifier(DefaultCellStyle())
        Text(song.title ?? String()).modifier(DefaultCellStyle())
        Text(song.artist ?? String()).modifier(DefaultCellStyle())
        Text(song.album ?? String()).modifier(DefaultCellStyle())
        Text(song.comment ?? String()).modifier(DefaultCellStyle())
        Text(song.grouping ?? String()).modifier(DefaultCellStyle())
        Text(song.key ?? String()).modifier(DefaultCellStyle())
        switch song.result {
        case .none:
            Text(String()).modifier(DefaultCellStyle())
        case .success(let result):
            Text(result).modifier(SuccessCellStyle())
        case .failure(let result):
            Text(result).modifier(FailureCellStyle())
        }
    }
}

struct SongRow: View {

    let song: SongViewModel

    var body: some View {
        HStack(spacing: cellSpacing) {
            SongCells(song: song)
        }
        .contextMenu {
            // TODO Add tagging I guess?
            Button(action: {
                // TODO show in finder.
            }, label: {
                Text("Show in Finder")
            })
        }
    }
}

struct RowSpacingStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.listRowInsets(
            EdgeInsets(
                top: cellSpacing / 2,
                leading: cellSpacing / 2,
                bottom: cellSpacing / 2,
                trailing: cellSpacing / 2
            )
        )
    }
}

struct BaseCellStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .lineLimit(1)
            .padding(.leading, cellSpacing)
            .padding(.trailing, cellSpacing)
            .padding(.top, cellSpacing)
            .padding(.bottom, cellSpacing)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.gridColor), lineWidth: 1)
            )
    }
}

struct HeaderCellStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity)
            .modifier(BaseCellStyle())
            .foregroundColor(Color(.secondaryLabelColor))
    }
}

struct DefaultCellStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .modifier(BaseCellStyle())
            .foregroundColor(Color(.labelColor))
    }
}

struct SuccessCellStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .modifier(BaseCellStyle())
            .foregroundColor(.green)
    }
}

struct FailureCellStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .modifier(BaseCellStyle())
            .foregroundColor(.red)
    }
}
