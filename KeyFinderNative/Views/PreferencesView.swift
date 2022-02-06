//
//  PreferencesView.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 31/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import SwiftUI
import Combine

struct PreferencesView: View {

    let window: NSWindow

    @State private var preferences = Preferences()

    var body: some View {
        VStack {
            Toggle(
                isOn: $preferences.writeAutomatically,
                label: { Text("Write to tags automatically", comment: "Preferences toggle label") }
            )
            Toggle(
                isOn: $preferences.skipFilesWithExistingMetadata,
                label: { Text("Skip files that already have metadata", comment: "Preferences toggle label") }
            )
            HStack {
                Text("Skip files longer than (minutes)", comment: "Preferences field label")
                TextField(
                    String(),
                    value: $preferences.skipFilesLongerThanMinutes,
                    formatter: NumberFormatter()
                )
                    .disableAutocorrection(true)
                    .frame(width: 48, height: nil, alignment: .trailing)
            }
            Divider()
            HStack {
                VStack {
                    Text("Tagging", comment: "Preferences section header")
                    Picker(
                        selection: $preferences.whatToWrite,
                        label: Text(
                            "What to write",
                            comment: "Preferences field label"
                        )
                    ) {
                        ForEach(Preferences.WhatToWrite.allCases) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Text(
                        "Where to write",
                        comment: "Preferences section header"
                    )
                    Picker(
                        selection: $preferences.howToWriteToTitleField,
                        label: Text(
                            "Title tag",
                            comment: "Preferences field label"
                        )
                    ) {
                        ForEach(Preferences.HowToWrite.options(for: .title)) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Picker(
                        selection: $preferences.howToWriteToArtistField,
                        label: Text(
                            "Artist tag",
                            comment: "Preferences field label"
                        )
                    ) {
                        ForEach(Preferences.HowToWrite.options(for: .artist)) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Picker(
                        selection: $preferences.howToWriteToAlbumField,
                        label: Text(
                            "Album tag",
                            comment: "Preferences field label"
                        )
                    ) {
                        ForEach(Preferences.HowToWrite.options(for: .album)) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Picker(
                        selection: $preferences.howToWriteToCommentField,
                        label: Text(
                            "Comment tag",
                            comment: "Preferences field label"
                        )
                    ) {
                        ForEach(Preferences.HowToWrite.options(for: .comment)) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Picker(
                        selection: $preferences.howToWriteToGroupingField,
                        label: Text(
                            "Grouping tag",
                            comment: "Preferences field label"
                        )
                    ) {
                        ForEach(Preferences.HowToWrite.options(for: .grouping)) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Picker(
                        selection: $preferences.howToWriteToKeyField,
                        label: Text(
                            "Key tag",
                            comment: "Preferences field label"
                        )
                    ) {
                        ForEach(Preferences.HowToWrite.options(for: .key)) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    HStack {
                        Text(
                            "Delimiter for prepend/append",
                             comment: "Preferences field label"
                        )
                        TextField(
                            String(),
                            text: $preferences.fieldDelimiter
                        )
                            .disableAutocorrection(true)
                            .frame(width: 48, height: nil, alignment: .trailing)
                    }
                    .disabled(
                        preferences.howToWriteToTitleField != .prepend
                        && preferences.howToWriteToArtistField != .prepend
                        && preferences.howToWriteToAlbumField != .prepend
                        && preferences.howToWriteToCommentField != .prepend
                        && preferences.howToWriteToGroupingField != .prepend
                        && preferences.howToWriteToTitleField != .append
                        && preferences.howToWriteToArtistField != .append
                        && preferences.howToWriteToAlbumField != .append
                        && preferences.howToWriteToCommentField != .append
                        && preferences.howToWriteToGroupingField != .append
                    )
                }
                Divider()
                VStack {
                    Text(
                        "Custom key codes",
                        comment: "Preferences section header"
                    )
                    HStack {
                        keyCode(
                            text: Text(Key.AMajor.description),
                            binding: $preferences.customCodesMajor[0]
                        )
                        keyCode(
                            text: Text(Key.BFlatMajor.description),
                            binding: $preferences.customCodesMajor[1]
                        )
                        keyCode(
                            text: Text(Key.BMajor.description),
                            binding: $preferences.customCodesMajor[2]
                        )
                        keyCode(
                            text: Text(Key.CMajor.description),
                            binding: $preferences.customCodesMajor[3]
                        )
                        keyCode(
                            text: Text(Key.DFlatMajor.description),
                            binding: $preferences.customCodesMajor[4]
                        )
                        keyCode(
                            text: Text(Key.DMajor.description),
                            binding: $preferences.customCodesMajor[5]
                        )
                    }
                    HStack {
                        keyCode(
                            text: Text(Key.EFlatMajor.description),
                            binding: $preferences.customCodesMajor[6]
                        )
                        keyCode(
                            text: Text(Key.EMajor.description),
                            binding: $preferences.customCodesMajor[7]
                        )
                        keyCode(
                            text: Text(Key.FMajor.description),
                            binding: $preferences.customCodesMajor[8]
                        )
                        keyCode(
                            text: Text(Key.GFlatMajor.description),
                            binding: $preferences.customCodesMajor[9]
                        )
                        keyCode(
                            text: Text(Key.GMajor.description),
                            binding: $preferences.customCodesMajor[10]
                        )
                        keyCode(
                            text: Text(Key.AFlatMajor.description),
                            binding: $preferences.customCodesMajor[11]
                        )
                    }
                    HStack {
                        keyCode(
                            text: Text(Key.AMinor.description),
                            binding: $preferences.customCodesMinor[0]
                        )
                        keyCode(
                            text: Text(Key.BFlatMinor.description),
                            binding: $preferences.customCodesMinor[1]
                        )
                        keyCode(
                            text: Text(Key.BMinor.description),
                            binding: $preferences.customCodesMinor[2]
                        )
                        keyCode(
                            text: Text(Key.CMinor.description),
                            binding: $preferences.customCodesMinor[3]
                        )
                        keyCode(
                            text: Text(Key.DFlatMinor.description),
                            binding: $preferences.customCodesMinor[4]
                        )
                        keyCode(
                            text: Text(Key.DMinor.description),
                            binding: $preferences.customCodesMinor[5]
                        )
                    }
                    HStack {
                        keyCode(
                            text: Text(Key.EFlatMinor.description),
                            binding: $preferences.customCodesMinor[6]
                        )
                        keyCode(
                            text: Text(Key.EMinor.description),
                            binding: $preferences.customCodesMinor[7]
                        )
                        keyCode(
                            text: Text(Key.FMinor.description),
                            binding: $preferences.customCodesMinor[8]
                        )
                        keyCode(
                            text: Text(Key.GFlatMinor.description),
                            binding: $preferences.customCodesMinor[9]
                        )
                        keyCode(
                            text: Text(Key.GMinor.description),
                            binding: $preferences.customCodesMinor[10]
                        )
                        keyCode(
                            text: Text(Key.AFlatMinor.description),
                            binding: $preferences.customCodesMinor[11]
                        )
                    }
                    // TODO this doesn't look right at all.
                    HStack {
                        Spacer()
                        keyCode(
                            text: Text("Silence", comment: "Preferences field label"),
                            binding: $preferences.customCodeSilence
                        )
                    }
                }
            }.padding()
            HStack {
                Button(
                    action: {
                        window.close()
                    },
                    label: {
                        Text("Cancel", comment: "Preferences button label")
                    }
                )
                Button(
                    action: {
                        preferences.save()
                        window.close()
                    },
                    label: {
                        Text("Save", comment: "Preferences button label")
                    }
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fixedSize()
    }
}

extension PreferencesView {

    private func keyCode(text: Text, binding: Binding<String>) -> some View {
        return HStack {
            text
                .frame(width: 34)
            TextField(
                String(),
                text: binding
            )
                .disableAutocorrection(true)
                .frame(width: 48)
        }
    }
}


struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(window: NSWindow())
    }
}
