//
//  PreferencesTests.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 06/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import XCTest
@testable import KeyFinder

final class PreferencesTests: XCTestCase {

    func testThatTheHowToWriteOptionsForEachTagFieldDontChange() {
        XCTAssertEqual([.no, .prepend, .append], Preferences.HowToWrite.options(for: .title))
        XCTAssertEqual([.no, .prepend, .append], Preferences.HowToWrite.options(for: .artist))
        XCTAssertEqual([.no, .prepend, .append], Preferences.HowToWrite.options(for: .album))
        XCTAssertEqual([.no, .prepend, .append, .overwrite], Preferences.HowToWrite.options(for: .comment))
        XCTAssertEqual([.no, .prepend, .append, .overwrite], Preferences.HowToWrite.options(for: .grouping))
        XCTAssertEqual([.no, .overwrite], Preferences.HowToWrite.options(for: .key))
    }

    func testThatHowToWriteToFieldReturnsTheAppropriateData() {
        var preferences = Preferences()
        preferences.howToWriteToTitleField = .no
        preferences.howToWriteToArtistField = .no
        preferences.howToWriteToAlbumField = .no
        preferences.howToWriteToCommentField = .no
        preferences.howToWriteToGroupingField = .no
        preferences.howToWriteToKeyField = .no

        XCTAssertEqual(
            [.no, .no, .no, .no, .no, .no],
            SongTagField.allCases.map { preferences.howToWrite(to: $0) }
        )

        preferences.howToWriteToTitleField = .prepend

        XCTAssertEqual(
            [.prepend, .no, .no, .no, .no, .no],
            SongTagField.allCases.map { preferences.howToWrite(to: $0) }
        )

        preferences.howToWriteToTitleField = .no
        preferences.howToWriteToArtistField = .append

        XCTAssertEqual(
            [.no, .append, .no, .no, .no, .no],
            SongTagField.allCases.map { preferences.howToWrite(to: $0) }
        )

        preferences.howToWriteToArtistField = .no
        preferences.howToWriteToAlbumField = .prepend

        XCTAssertEqual(
            [.no, .no, .prepend, .no, .no, .no],
            SongTagField.allCases.map { preferences.howToWrite(to: $0) }
        )

        preferences.howToWriteToAlbumField = .no
        preferences.howToWriteToCommentField = .overwrite

        XCTAssertEqual(
            [.no, .no, .no, .overwrite, .no, .no],
            SongTagField.allCases.map { preferences.howToWrite(to: $0) }
        )

        preferences.howToWriteToCommentField = .no
        preferences.howToWriteToGroupingField = .append

        XCTAssertEqual(
            [.no, .no, .no, .no, .append, .no],
            SongTagField.allCases.map { preferences.howToWrite(to: $0) }
        )

        preferences.howToWriteToGroupingField = .no
        preferences.howToWriteToKeyField = .overwrite

        XCTAssertEqual(
            [.no, .no, .no, .no, .no, .overwrite],
            SongTagField.allCases.map { preferences.howToWrite(to: $0) }
        )
    }

    func testDefaultsAndStorage() {

        let store = FakePreferencesStorage()
        let px = "uk.co.ibrahimshaath.keyfinder."

        XCTAssertNil(store.value(forKey: "\(px)writeAutomatically"))
        XCTAssertNil(store.value(forKey: "\(px)skipFilesWithExistingMetadata"))
        XCTAssertNil(store.value(forKey: "\(px)skipFilesLongerThanMinutes"))
        XCTAssertNil(store.value(forKey: "\(px)whatToWrite"))
        XCTAssertNil(store.value(forKey: "\(px)howToWriteToTitleField"))
        XCTAssertNil(store.value(forKey: "\(px)howToWriteToArtistField"))
        XCTAssertNil(store.value(forKey: "\(px)howToWriteToAlbumField"))
        XCTAssertNil(store.value(forKey: "\(px)howToWriteToCommentField"))
        XCTAssertNil(store.value(forKey: "\(px)howToWriteToGroupingField"))
        XCTAssertNil(store.value(forKey: "\(px)howToWriteToKeyField"))
        XCTAssertNil(store.value(forKey: "\(px)fieldDelimiter"))
        XCTAssertNil(store.value(forKey: "\(px)customCodesMajor"))
        XCTAssertNil(store.value(forKey: "\(px)customCodesMinor"))
        XCTAssertNil(store.value(forKey: "\(px)customCodesSilence"))

        var writingPreferences = Preferences(from: store)

        XCTAssertEqual(false, writingPreferences.writeAutomatically)
        XCTAssertEqual(false, writingPreferences.skipFilesWithExistingMetadata)
        XCTAssertEqual(30, writingPreferences.skipFilesLongerThanMinutes)
        XCTAssertEqual(.keys, writingPreferences.whatToWrite)
        XCTAssertEqual(.no, writingPreferences.howToWriteToTitleField)
        XCTAssertEqual(.no, writingPreferences.howToWriteToArtistField)
        XCTAssertEqual(.no, writingPreferences.howToWriteToAlbumField)
        XCTAssertEqual(.overwrite, writingPreferences.howToWriteToCommentField)
        XCTAssertEqual(.no, writingPreferences.howToWriteToGroupingField)
        XCTAssertEqual(.no, writingPreferences.howToWriteToKeyField)
        XCTAssertEqual(" - ", writingPreferences.fieldDelimiter)
        XCTAssertEqual(
            ["4d", "11d", "6d", "1d", "8d", "3d", "10d", "5d", "12d", "7d", "2d", "9d"],
            writingPreferences.customCodesMajor
        )
        XCTAssertEqual(
            ["1m", "8m", "3m", "10m", "5m", "12m", "7m", "2m", "9m", "4m", "11m", "6m"],
            writingPreferences.customCodesMinor
        )
        XCTAssertEqual("", writingPreferences.customCodeSilence)

        writingPreferences.writeAutomatically = true
        writingPreferences.skipFilesWithExistingMetadata = true
        writingPreferences.skipFilesLongerThanMinutes = 25
        writingPreferences.whatToWrite = .both
        writingPreferences.howToWriteToTitleField = .append
        writingPreferences.howToWriteToArtistField = .prepend
        writingPreferences.howToWriteToAlbumField = .append
        writingPreferences.howToWriteToCommentField = .prepend
        writingPreferences.howToWriteToGroupingField = .append
        writingPreferences.howToWriteToKeyField = .overwrite
        writingPreferences.fieldDelimiter = "🔥"
        writingPreferences.customCodesMajor = ["ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "ELEVEN", "TWELVE"]
        writingPreferences.customCodesMinor = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve"]
        writingPreferences.customCodeSilence = "🐈‍⬛"

        writingPreferences.save(to: store)

        XCTAssertNotNil(store.value(forKey: "\(px)writeAutomatically"))
        XCTAssertNotNil(store.value(forKey: "\(px)skipFilesWithExistingMetadata"))
        XCTAssertNotNil(store.value(forKey: "\(px)skipFilesLongerThanMinutes"))
        XCTAssertNotNil(store.value(forKey: "\(px)whatToWrite"))
        XCTAssertNotNil(store.value(forKey: "\(px)howToWriteToTitleField"))
        XCTAssertNotNil(store.value(forKey: "\(px)howToWriteToArtistField"))
        XCTAssertNotNil(store.value(forKey: "\(px)howToWriteToAlbumField"))
        XCTAssertNotNil(store.value(forKey: "\(px)howToWriteToCommentField"))
        XCTAssertNotNil(store.value(forKey: "\(px)howToWriteToGroupingField"))
        XCTAssertNotNil(store.value(forKey: "\(px)howToWriteToKeyField"))
        XCTAssertNotNil(store.value(forKey: "\(px)fieldDelimiter"))
        XCTAssertNotNil(store.value(forKey: "\(px)customCodesMajor"))
        XCTAssertNotNil(store.value(forKey: "\(px)customCodesMinor"))
        XCTAssertNotNil(store.value(forKey: "\(px)customCodesSilence"))

        let readingPreferences = Preferences(from: store)

        XCTAssertEqual(true, readingPreferences.writeAutomatically)
        XCTAssertEqual(true, readingPreferences.skipFilesWithExistingMetadata)
        XCTAssertEqual(25, readingPreferences.skipFilesLongerThanMinutes)
        XCTAssertEqual(.both, readingPreferences.whatToWrite)
        XCTAssertEqual(.append, readingPreferences.howToWriteToTitleField)
        XCTAssertEqual(.prepend, readingPreferences.howToWriteToArtistField)
        XCTAssertEqual(.append, readingPreferences.howToWriteToAlbumField)
        XCTAssertEqual(.prepend, readingPreferences.howToWriteToCommentField)
        XCTAssertEqual(.append, readingPreferences.howToWriteToGroupingField)
        XCTAssertEqual(.overwrite, readingPreferences.howToWriteToKeyField)
        XCTAssertEqual("🔥", readingPreferences.fieldDelimiter)
        XCTAssertEqual(
            ["ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "ELEVEN", "TWELVE"],
            readingPreferences.customCodesMajor
        )
        XCTAssertEqual(
            ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve"],
            readingPreferences.customCodesMinor
        )
        XCTAssertEqual("🐈‍⬛", readingPreferences.customCodeSilence)
    }
}
