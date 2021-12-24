//
//  PreferencesView.swift
//  KeyFinderNative
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
            Toggle("Write to tags automatically during batch jobs", isOn: $preferences.writeAutomatically)
            Toggle("Skip files that already have metadata", isOn: $preferences.skipFilesWithExistingMetadata)
            HStack {
                Text("Skip files longer than (minutes)")
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
                    Text("Tagging")
                    Picker(selection: $preferences.whatToWrite, label: Text("What to write")) {
                        ForEach(Preferences.WhatToWrite.allCases) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Text("Where to write")
                    Picker(selection: $preferences.howToWriteToTitleTag, label: Text("Title tag")) {
                        ForEach(Preferences.HowToWrite.titleTagOptions) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Picker(selection: $preferences.howToWriteToArtistTag, label: Text("Artist tag")) {
                        ForEach(Preferences.HowToWrite.artistTagOptions) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Picker(selection: $preferences.howToWriteToAlbumTag, label: Text("Album tag")) {
                        ForEach(Preferences.HowToWrite.albumTagOptions) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Picker(selection: $preferences.howToWriteToCommentTag, label: Text("Comment tag")) {
                        ForEach(Preferences.HowToWrite.commentTagOptions) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Picker(selection: $preferences.howToWriteToGroupingTag, label: Text("Grouping tag")) {
                        ForEach(Preferences.HowToWrite.groupingTagOptions) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    Picker(selection: $preferences.howToWriteToKeyTag, label: Text("Key tag")) {
                        ForEach(Preferences.HowToWrite.keyTagOptions) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    HStack {
                        Text("Delimiter for prepend/append")
                        TextField(
                            String(),
                            text: $preferences.tagDelimiter
                        )
                        .disableAutocorrection(true)
                        .frame(width: 48, height: nil, alignment: .trailing)
                    }
                    .disabled(
                        preferences.howToWriteToTitleTag != .prepend
                            && preferences.howToWriteToArtistTag != .prepend
                            && preferences.howToWriteToAlbumTag != .prepend
                            && preferences.howToWriteToCommentTag != .prepend
                            && preferences.howToWriteToGroupingTag != .prepend
                            && preferences.howToWriteToTitleTag != .append
                            && preferences.howToWriteToArtistTag != .append
                            && preferences.howToWriteToAlbumTag != .append
                            && preferences.howToWriteToCommentTag != .append
                            && preferences.howToWriteToGroupingTag != .append
                    )
                }
                Divider()
                VStack {
                    Text("Custom key codes")
                    HStack {
                        keyCode(text: "A", binding: $preferences.customCodesMajor[0])
                        keyCode(text: "Bb", binding: $preferences.customCodesMajor[1])
                        keyCode(text: "B", binding: $preferences.customCodesMajor[2])
                        keyCode(text: "C", binding: $preferences.customCodesMajor[3])
                        keyCode(text: "Db", binding: $preferences.customCodesMajor[4])
                        keyCode(text: "D", binding: $preferences.customCodesMajor[5])
                    }
                    HStack {
                        keyCode(text: "Eb", binding: $preferences.customCodesMajor[6])
                        keyCode(text: "E", binding: $preferences.customCodesMajor[7])
                        keyCode(text: "F", binding: $preferences.customCodesMajor[8])
                        keyCode(text: "Gb", binding: $preferences.customCodesMajor[9])
                        keyCode(text: "G", binding: $preferences.customCodesMajor[10])
                        keyCode(text: "Ab", binding: $preferences.customCodesMajor[11])
                    }
                    HStack {
                        keyCode(text: "Am", binding: $preferences.customCodesMinor[0])
                        keyCode(text: "Bbm", binding: $preferences.customCodesMinor[1])
                        keyCode(text: "Bm", binding: $preferences.customCodesMinor[2])
                        keyCode(text: "Cm", binding: $preferences.customCodesMinor[3])
                        keyCode(text: "Dbm", binding: $preferences.customCodesMinor[4])
                        keyCode(text: "Dm", binding: $preferences.customCodesMinor[5])
                    }
                    HStack {
                        keyCode(text: "Ebm", binding: $preferences.customCodesMinor[6])
                        keyCode(text: "Em", binding: $preferences.customCodesMinor[7])
                        keyCode(text: "Fm", binding: $preferences.customCodesMinor[8])
                        keyCode(text: "Gbm", binding: $preferences.customCodesMinor[9])
                        keyCode(text: "Gm", binding: $preferences.customCodesMinor[10])
                        keyCode(text: "Abm", binding: $preferences.customCodesMinor[11])
                    }
                    // TODO this doesn't look right at all.
                    HStack {
                        Spacer()
                        keyCode(text: "None", binding: $preferences.customCodeSilence)
                    }
                }
            }.padding()
            HStack {
                Button("Cancel", action: {
                    window.close()
                })
                Button("Save", action: {
                    preferences.save()
                    window.close()
                })
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fixedSize()
    }
}

extension PreferencesView {

    private func keyCode(text: String, binding: Binding<String>) -> some View {
        return HStack {
            Text(text)
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
