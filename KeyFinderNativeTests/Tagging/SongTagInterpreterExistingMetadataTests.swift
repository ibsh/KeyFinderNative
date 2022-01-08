//
//  SongTagInterpreterExistingMetadataTests.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 07/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import XCTest
@testable import KeyFinder

final class SongTagInterpreterExistingMetadataTests: XCTestCase {

    // These tests are not comprehensive because I would have died.

    private var preferences: Preferences!

    override func setUp() {
        // always start with clean preferences
        preferences = Preferences(from: FakePreferencesStorage())
        preferences.whatToWrite = .keys
        preferences.howToWriteToTitleField = .no
        preferences.howToWriteToArtistField = .no
        preferences.howToWriteToAlbumField = .no
        preferences.howToWriteToCommentField = .no
        preferences.howToWriteToGroupingField = .no
        preferences.howToWriteToKeyField = .no
        preferences.fieldDelimiter = "_"
    }

    func testThatNotWritingYieldsFalseRegardlessOfContents() {

        let interpreter = SongTagInterpreter(preferences: preferences)

        XCTAssertFalse(
            interpreter.allRelevantFieldsContainExistingMetadata(
                tagStore: SongTagStore(
                    title: nil,
                    artist: nil,
                    album: nil,
                    comment: nil,
                    grouping: nil,
                    key: nil
                )
            )
        )
    }

    func testThatAppendingToCommentYieldsTrueIfCommentMatchesSomeKey() {

        preferences.howToWriteToCommentField = .append
        let interpreter = SongTagInterpreter(preferences: preferences)

        XCTAssertTrue(
            interpreter.allRelevantFieldsContainExistingMetadata(
                tagStore: SongTagStore(
                    title: nil,
                    artist: nil,
                    album: nil,
                    comment: "D",
                    grouping: nil,
                    key: nil
                )
            )
        )
    }

    func testThatAppendingToCommentYieldsTrueIfCommentIsSuffixedWithSomeKey() {

        preferences.howToWriteToCommentField = .append
        let interpreter = SongTagInterpreter(preferences: preferences)

        XCTAssertTrue(
            interpreter.allRelevantFieldsContainExistingMetadata(
                tagStore: SongTagStore(
                    title: nil,
                    artist: nil,
                    album: nil,
                    comment: "COMMENT_Am",
                    grouping: nil,
                    key: nil
                )
            )
        )
    }

    func testThatAppendingToCommentYieldsFalseIfCommentIsPrefixedWithSomeKey() {

        preferences.howToWriteToCommentField = .append
        let interpreter = SongTagInterpreter(preferences: preferences)

        XCTAssertFalse(
            interpreter.allRelevantFieldsContainExistingMetadata(
                tagStore: SongTagStore(
                    title: nil,
                    artist: nil,
                    album: nil,
                    comment: "F_COMMENT",
                    grouping: nil,
                    key: nil
                )
            )
        )
    }

    func testThatAppendingToCommentYieldsFalseIfCommentIsNotConflicting() {

        preferences.howToWriteToCommentField = .append
        let interpreter = SongTagInterpreter(preferences: preferences)

        XCTAssertFalse(
            interpreter.allRelevantFieldsContainExistingMetadata(
                tagStore: SongTagStore(
                    title: nil,
                    artist: nil,
                    album: nil,
                    comment: "COMMENT",
                    grouping: nil,
                    key: nil
                )
            )
        )
    }

    func testThatAppendingToCommentYieldsFalseRegardlessOfConflictsInOtherFields() {

        preferences.howToWriteToCommentField = .append
        let interpreter = SongTagInterpreter(preferences: preferences)

        XCTAssertFalse(
            interpreter.allRelevantFieldsContainExistingMetadata(
                tagStore: SongTagStore(
                    title: "F",
                    artist: "Am_ARTIST",
                    album: "ALBUM_Dm",
                    comment: "COMMENT",
                    grouping: "Fm_GROUPING",
                    key: "G"
                )
            )
        )
    }

    func testForMoreThanOneField() {

        preferences.howToWriteToCommentField = .append
        preferences.howToWriteToGroupingField = .prepend
        preferences.howToWriteToKeyField = .overwrite
        let interpreter = SongTagInterpreter(preferences: preferences)

        XCTAssertFalse(
            interpreter.allRelevantFieldsContainExistingMetadata(
                tagStore: SongTagStore(
                    title: nil,
                    artist: nil,
                    album: nil,
                    comment: "COMMENT_Am",
                    grouping: "Fm_GROUPING",
                    key: nil
                )
            )
        )

        XCTAssertFalse(
            interpreter.allRelevantFieldsContainExistingMetadata(
                tagStore: SongTagStore(
                    title: nil,
                    artist: nil,
                    album: nil,
                    comment: "COMMENT_Am",
                    grouping: "GROUPING",
                    key: "Gbm"
                )
            )
        )

        XCTAssertFalse(
            interpreter.allRelevantFieldsContainExistingMetadata(
                tagStore: SongTagStore(
                    title: nil,
                    artist: nil,
                    album: nil,
                    comment: "COMMENT",
                    grouping: "Fm_GROUPING",
                    key: "Gbm"
                )
            )
        )

        XCTAssertTrue(
            interpreter.allRelevantFieldsContainExistingMetadata(
                tagStore: SongTagStore(
                    title: nil,
                    artist: nil,
                    album: nil,
                    comment: "COMMENT_Bbm",
                    grouping: "Fm_GROUPING",
                    key: "Gbm"
                )
            )
        )
    }
}
