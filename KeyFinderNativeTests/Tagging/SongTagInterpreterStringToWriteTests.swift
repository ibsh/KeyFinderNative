//
//  SongTagInterpreterStringToWriteTests.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 06/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import XCTest
@testable import KeyFinder

// swiftlint:disable type_body_length
final class SongTagInterpreterStringToWriteTests: XCTestCase {

    private var preferences: Preferences!

    override func setUp() {
        // always start with clean preferences
        preferences = Preferences(from: FakePreferencesStorage())
        preferences.whatToWrite = .keys
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .overwrite
        preferences.howToWriteToGroupingField = .overwrite
        preferences.howToWriteToKeyField = .overwrite
    }

    func testThatOutputReflectsKey() {
        let tagStore = SongTagStore(
            title: "T",
            artist: "R",
            album: "L",
            comment: "C",
            grouping: "G",
            key: "K"
        )
        let expectedValuesForAMinor: [String?] = [
            "Am - T",
            "Am - R",
            "Am - L",
            "Am",
            "Am",
            "Am",
        ]
        let expectedValuesForDMajor: [String?] = [
            "D - T",
            "D - R",
            "D - L",
            "D",
            "D",
            "D",
        ]
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValuesForAMinor: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        let actualValuesForDMajor: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .DMajor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValuesForAMinor,
            actualValuesForAMinor
        )
        XCTAssertEqual(
            expectedValuesForDMajor,
            actualValuesForDMajor
        )
    }

    func testThatOutputReflectsWhatToWrite() {
        let tagStore = SongTagStore(
            title: "T",
            artist: "R",
            album: "L",
            comment: "C",
            grouping: "G",
            key: "K"
        )
        let expectedValuesForCustomCodes: [String?] = [
            "1m - T",
            "1m - R",
            "1m - L",
            "1m",
            "1m",
            "1m",
        ]
        let expectedValuesForKeys: [String?] = [
            "Am - T",
            "Am - R",
            "Am - L",
            "Am",
            "Am",
            "Am",
        ]
        let expectedValuesForBoth: [String?] = [
            "1m Am - T",
            "1m Am - R",
            "1m Am - L",
            "1m Am",
            "1m Am",
            "1m",
        ]
        preferences.whatToWrite = .customCodes
        let interpreterForCustomCodes = SongTagInterpreter(preferences: preferences)
        let actualValuesForCustomCodes: [String?] = SongTagField.allCases.map { field in
            interpreterForCustomCodes.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        preferences.whatToWrite = .keys
        let interpreterForKeys = SongTagInterpreter(preferences: preferences)
        let actualValuesForKeys: [String?] = SongTagField.allCases.map { field in
            interpreterForKeys.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        preferences.whatToWrite = .both
        let interpreterForBoth = SongTagInterpreter(preferences: preferences)
        let actualValuesForBoth: [String?] = SongTagField.allCases.map { field in
            interpreterForBoth.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValuesForCustomCodes,
            actualValuesForCustomCodes
        )
        XCTAssertEqual(
            expectedValuesForKeys,
            actualValuesForKeys
        )
        XCTAssertEqual(
            expectedValuesForBoth,
            actualValuesForBoth
        )
    }

    func testThatOutputReflectsDelimiter() {
        let tagStore = SongTagStore(
            title: "T",
            artist: "R",
            album: "L",
            comment: "C",
            grouping: "G",
            key: "K"
        )
        let expectedValuesForCat: [String?] = [
            "Am🐈‍⬛T",
            "Am🐈‍⬛R",
            "Am🐈‍⬛L",
            "Am",
            "Am",
            "Am",
        ]
        let expectedValuesForSpade: [String?] = [
            "Am♠️T",
            "Am♠️R",
            "Am♠️L",
            "Am",
            "Am",
            "Am",
        ]
        preferences.fieldDelimiter = "🐈‍⬛"
        let interpreterForCat = SongTagInterpreter(preferences: preferences)
        let actualValuesForCat: [String?] = SongTagField.allCases.map { field in
            interpreterForCat.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        preferences.fieldDelimiter = "♠️"
        let interpreterForSpade = SongTagInterpreter(preferences: preferences)
        let actualValuesForSpade: [String?] = SongTagField.allCases.map { field in
            interpreterForSpade.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValuesForCat,
            actualValuesForCat
        )
        XCTAssertEqual(
            expectedValuesForSpade,
            actualValuesForSpade
        )
    }

    func testThatPrependWorksOnNil() {
        let tagStore = SongTagStore(
            title: nil,
            artist: nil,
            album: nil,
            comment: nil,
            grouping: nil,
            key: nil
        )
        let expectedValues: [String?] = [
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .prepend
        preferences.howToWriteToGroupingField = .prepend
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatPrependWorksOnEmpty() {
        let tagStore = SongTagStore(
            title: "",
            artist: "",
            album: "",
            comment: "",
            grouping: "",
            key: ""
        )
        let expectedValues: [String?] = [
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .prepend
        preferences.howToWriteToGroupingField = .prepend
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatPrependWorksOnBlank() {
        let tagStore = SongTagStore(
            title: "   ",
            artist: "   ",
            album: "   ",
            comment: "   ",
            grouping: "   ",
            key: "   "
        )
        let expectedValues: [String?] = [
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .prepend
        preferences.howToWriteToGroupingField = .prepend
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatPrependWorksOnNonCollidingString() {
        let tagStore = SongTagStore(
            title: "T",
            artist: "R",
            album: "L",
            comment: "C",
            grouping: "G",
            key: "K"
        )
        let expectedValues: [String?] = [
            Optional("Am - T"),
            Optional("Am - R"),
            Optional("Am - L"),
            Optional("Am - C"),
            Optional("Am - G"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .prepend
        preferences.howToWriteToGroupingField = .prepend
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatPrependWorksOnCollidingString() {
        let tagStore = SongTagStore(
            title: "Am_T",
            artist: "Am_R",
            album: "Am_L",
            comment: "Am_C",
            grouping: "Am_G",
            key: "Am"
        )
        let expectedValues: [String?] = [
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        ]
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .prepend
        preferences.howToWriteToGroupingField = .prepend
        preferences.fieldDelimiter = "_"
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatAppendWorksOnNil() {
        let tagStore = SongTagStore(
            title: nil,
            artist: nil,
            album: nil,
            comment: nil,
            grouping: nil,
            key: nil
        )
        let expectedValues: [String?] = [
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .append
        preferences.howToWriteToArtistField = .append
        preferences.howToWriteToAlbumField = .append
        preferences.howToWriteToCommentField = .append
        preferences.howToWriteToGroupingField = .append
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatAppendWorksOnEmpty() {
        let tagStore = SongTagStore(
            title: "",
            artist: "",
            album: "",
            comment: "",
            grouping: "",
            key: ""
        )
        let expectedValues: [String?] = [
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .append
        preferences.howToWriteToArtistField = .append
        preferences.howToWriteToAlbumField = .append
        preferences.howToWriteToCommentField = .append
        preferences.howToWriteToGroupingField = .append
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatAppendWorksOnBlank() {
        let tagStore = SongTagStore(
            title: "   ",
            artist: "   ",
            album: "   ",
            comment: "   ",
            grouping: "   ",
            key: "   "
        )
        let expectedValues: [String?] = [
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .append
        preferences.howToWriteToArtistField = .append
        preferences.howToWriteToAlbumField = .append
        preferences.howToWriteToCommentField = .append
        preferences.howToWriteToGroupingField = .append
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatAppendWorksOnNonCollidingString() {
        let tagStore = SongTagStore(
            title: "T",
            artist: "R",
            album: "L",
            comment: "C",
            grouping: "G",
            key: "K"
        )
        let expectedValues: [String?] = [
            Optional("T - Am"),
            Optional("R - Am"),
            Optional("L - Am"),
            Optional("C - Am"),
            Optional("G - Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .append
        preferences.howToWriteToArtistField = .append
        preferences.howToWriteToAlbumField = .append
        preferences.howToWriteToCommentField = .append
        preferences.howToWriteToGroupingField = .append
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatAppendWorksOnCollidingString() {
        let tagStore = SongTagStore(
            title: "T_Am",
            artist: "R_Am",
            album: "L_Am",
            comment: "C_Am",
            grouping: "G_Am",
            key: "Am"
        )
        let expectedValues: [String?] = [
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        ]
        preferences.howToWriteToTitleField = .append
        preferences.howToWriteToArtistField = .append
        preferences.howToWriteToAlbumField = .append
        preferences.howToWriteToCommentField = .append
        preferences.howToWriteToGroupingField = .append
        preferences.fieldDelimiter = "_"
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatOverwriteWorksOnNil() {
        let tagStore = SongTagStore(
            title: nil,
            artist: nil,
            album: nil,
            comment: nil,
            grouping: nil,
            key: nil
        )
        let expectedValues: [String?] = [
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .overwrite
        preferences.howToWriteToGroupingField = .overwrite
        preferences.howToWriteToKeyField = .overwrite
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatOverwriteWorksOnEmpty() {
        let tagStore = SongTagStore(
            title: "",
            artist: "",
            album: "",
            comment: "",
            grouping: "",
            key: ""
        )
        let expectedValues: [String?] = [
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .overwrite
        preferences.howToWriteToGroupingField = .overwrite
        preferences.howToWriteToKeyField = .overwrite
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatOverwriteWorksOnBlank() {
        let tagStore = SongTagStore(
            title: "   ",
            artist: "   ",
            album: "   ",
            comment: "   ",
            grouping: "   ",
            key: "   "
        )
        let expectedValues: [String?] = [
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .overwrite
        preferences.howToWriteToGroupingField = .overwrite
        preferences.howToWriteToKeyField = .overwrite
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatOverwriteWorksOnNonCollidingString() {
        let tagStore = SongTagStore(
            title: "T",
            artist: "R",
            album: "L",
            comment: "C",
            grouping: "G",
            key: "K"
        )
        let expectedValues: [String?] = [
            Optional("Am - T"),
            Optional("Am - R"),
            Optional("Am - L"),
            Optional("Am"),
            Optional("Am"),
            Optional("Am"),
        ]
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .overwrite
        preferences.howToWriteToGroupingField = .overwrite
        preferences.howToWriteToKeyField = .overwrite
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatOverwriteWorksOnCollidingString() {
        let tagStore = SongTagStore(
            title: "Am",
            artist: "Am",
            album: "Am",
            comment: "Am",
            grouping: "Am",
            key: "Am"
        )
        let expectedValues: [String?] = [
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        ]
        preferences.howToWriteToTitleField = .prepend
        preferences.howToWriteToArtistField = .prepend
        preferences.howToWriteToAlbumField = .prepend
        preferences.howToWriteToCommentField = .overwrite
        preferences.howToWriteToGroupingField = .overwrite
        preferences.howToWriteToKeyField = .overwrite
        preferences.fieldDelimiter = "_"
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatNoHasNoEffectOnNil() {
        let tagStore = SongTagStore(
            title: nil,
            artist: nil,
            album: nil,
            comment: nil,
            grouping: nil,
            key: nil
        )
        let expectedValues: [String?] = [
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        ]
        preferences.howToWriteToTitleField = .no
        preferences.howToWriteToArtistField = .no
        preferences.howToWriteToAlbumField = .no
        preferences.howToWriteToCommentField = .no
        preferences.howToWriteToGroupingField = .no
        preferences.howToWriteToKeyField = .no
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatNoHasNoEffectOnEmpty() {
        let tagStore = SongTagStore(
            title: "",
            artist: "",
            album: "",
            comment: "",
            grouping: "",
            key: ""
        )
        let expectedValues: [String?] = [
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        ]
        preferences.howToWriteToTitleField = .no
        preferences.howToWriteToArtistField = .no
        preferences.howToWriteToAlbumField = .no
        preferences.howToWriteToCommentField = .no
        preferences.howToWriteToGroupingField = .no
        preferences.howToWriteToKeyField = .no
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatNoHasNoEffectOnBlank() {
        let tagStore = SongTagStore(
            title: "   ",
            artist: "   ",
            album: "   ",
            comment: "   ",
            grouping: "   ",
            key: "   "
        )
        let expectedValues: [String?] = [
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        ]
        preferences.howToWriteToTitleField = .no
        preferences.howToWriteToArtistField = .no
        preferences.howToWriteToAlbumField = .no
        preferences.howToWriteToCommentField = .no
        preferences.howToWriteToGroupingField = .no
        preferences.howToWriteToKeyField = .no
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }

    func testThatNoHasNoEffectOnNonBlank() {
        let tagStore = SongTagStore(
            title: "T",
            artist: "R",
            album: "L",
            comment: "C",
            grouping: "G",
            key: "K"
        )
        let expectedValues: [String?] = [
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        ]
        preferences.howToWriteToTitleField = .no
        preferences.howToWriteToArtistField = .no
        preferences.howToWriteToAlbumField = .no
        preferences.howToWriteToCommentField = .no
        preferences.howToWriteToGroupingField = .no
        preferences.howToWriteToKeyField = .no
        let interpreter = SongTagInterpreter(preferences: preferences)
        let actualValues: [String?] = SongTagField.allCases.map { field in
            interpreter.stringToWrite(
                field: field,
                key: .AMinor,
                tagStore: tagStore
            )
        }
        XCTAssertEqual(
            expectedValues,
            actualValues
        )
    }
}
