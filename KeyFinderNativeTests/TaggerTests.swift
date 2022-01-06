//
//  TaggerTests.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import XCTest
@testable import KeyFinderNative
@testable import KeyFinder

final class TaggerTests: XCTestCase {

    private let preferences = KeyFinder.Preferences()
    private let wrapper = FakeTagIOWrapper()
    private let tagInterpreter = {
        SongTagInterpreterSpy(
            preferences: KeyFinder.Preferences()
        )
    }()

    func testReadTags() {

        var tagInterpreterFactoryInvocations = 0

        let tagger = Tagger(
            url: URL(fileURLWithPath: ""),
            wrapperFactory: { _ in self.wrapper },
            tagInterpreterFactory: { (_) in
                tagInterpreterFactoryInvocations += 1
                return self.tagInterpreter
            },
            preferences: preferences
        )

        wrapper.titleValue = "TITLE"
        wrapper.artistValue = "ARTIST"
        wrapper.albumValue = "ALBUM"
        wrapper.commentValue = "COMMENT"
        wrapper.groupingValue = "GROUPING"
        wrapper.keyValue = "KEY"

        let noNilTags = tagger.readTags()

        XCTAssertEqual("TITLE", noNilTags.title)
        XCTAssertEqual("ARTIST", noNilTags.artist)
        XCTAssertEqual("ALBUM", noNilTags.album)
        XCTAssertEqual("COMMENT", noNilTags.comment)
        XCTAssertEqual("GROUPING", noNilTags.grouping)
        XCTAssertEqual("KEY", noNilTags.key)

        wrapper.titleValue = "a"
        wrapper.artistValue = "b"
        wrapper.albumValue = "c"
        wrapper.commentValue = nil
        wrapper.groupingValue = nil
        wrapper.keyValue = nil

        let lastHalfNilTags = tagger.readTags()

        XCTAssertEqual("a", lastHalfNilTags.title)
        XCTAssertEqual("b", lastHalfNilTags.artist)
        XCTAssertEqual("c", lastHalfNilTags.album)
        XCTAssertNil(lastHalfNilTags.comment)
        XCTAssertNil(lastHalfNilTags.grouping)
        XCTAssertNil(lastHalfNilTags.key)

        wrapper.titleValue = nil
        wrapper.artistValue = nil
        wrapper.albumValue = nil
        wrapper.commentValue = "d"
        wrapper.groupingValue = "e"
        wrapper.keyValue = "f"

        let firstHalfNilTags = tagger.readTags()

        XCTAssertNil(firstHalfNilTags.title)
        XCTAssertNil(firstHalfNilTags.artist)
        XCTAssertNil(firstHalfNilTags.album)
        XCTAssertEqual("d", firstHalfNilTags.comment)
        XCTAssertEqual("e", firstHalfNilTags.grouping)
        XCTAssertEqual("f", firstHalfNilTags.key)

        wrapper.titleValue = nil
        wrapper.artistValue = nil
        wrapper.albumValue = nil
        wrapper.commentValue = nil
        wrapper.groupingValue = nil
        wrapper.keyValue = nil

        let allNilTags = tagger.readTags()

        XCTAssertNil(allNilTags.title)
        XCTAssertNil(allNilTags.artist)
        XCTAssertNil(allNilTags.album)
        XCTAssertNil(allNilTags.comment)
        XCTAssertNil(allNilTags.grouping)
        XCTAssertNil(allNilTags.key)

        XCTAssertEqual(0, tagInterpreterFactoryInvocations)
        XCTAssertEqual(0, tagInterpreter.stringToWriteInvocations.count)
        XCTAssertEqual(0, tagInterpreter.allRelevantFieldsContainExistingMetadataInvocations.count)
    }

    func testWriteTags() {

        var tagInterpreterFactoryInvocations = 0

        let tagger = Tagger(
            url: URL(fileURLWithPath: ""),
            wrapperFactory: { _ in self.wrapper },
            tagInterpreterFactory: { (_) in
                tagInterpreterFactoryInvocations += 1
                return self.tagInterpreter
            },
            preferences: preferences
        )

        XCTAssertEqual(0, tagInterpreterFactoryInvocations)
        XCTAssertEqual(0, tagInterpreter.stringToWriteInvocations.count)
        XCTAssertEqual(0, tagInterpreter.allRelevantFieldsContainExistingMetadataInvocations.count)

        tagInterpreter.stringToWriteValues = [
            .title: "Jeff1",
            .artist: "Jeff2",
            .album: "Jeff3",
            .comment: "Jeff4",
            .grouping: "Jeff5",
            .key: "Jeff6",
        ]
        tagger.writeTags(key: .AMinor)

        let expectedTagStore1 = SongTagStore(
            title: nil,
            artist: nil,
            album: nil,
            comment: nil,
            grouping: nil,
            key: nil
        )

        XCTAssertEqual(1, tagInterpreterFactoryInvocations)
        XCTAssertEqual(6, tagInterpreter.stringToWriteInvocations.count)
        XCTAssertEqual(.title, tagInterpreter.stringToWriteInvocations[0].field)
        XCTAssertEqual(.artist, tagInterpreter.stringToWriteInvocations[1].field)
        XCTAssertEqual(.album, tagInterpreter.stringToWriteInvocations[2].field)
        XCTAssertEqual(.comment, tagInterpreter.stringToWriteInvocations[3].field)
        XCTAssertEqual(.grouping, tagInterpreter.stringToWriteInvocations[4].field)
        XCTAssertEqual(.key, tagInterpreter.stringToWriteInvocations[5].field)
        XCTAssertEqual(.AMinor, tagInterpreter.stringToWriteInvocations[0].key)
        XCTAssertEqual(.AMinor, tagInterpreter.stringToWriteInvocations[1].key)
        XCTAssertEqual(.AMinor, tagInterpreter.stringToWriteInvocations[2].key)
        XCTAssertEqual(.AMinor, tagInterpreter.stringToWriteInvocations[3].key)
        XCTAssertEqual(.AMinor, tagInterpreter.stringToWriteInvocations[4].key)
        XCTAssertEqual(.AMinor, tagInterpreter.stringToWriteInvocations[5].key)
        XCTAssertEqual(expectedTagStore1, tagInterpreter.stringToWriteInvocations[0].tagStore)
        XCTAssertEqual(expectedTagStore1, tagInterpreter.stringToWriteInvocations[1].tagStore)
        XCTAssertEqual(expectedTagStore1, tagInterpreter.stringToWriteInvocations[2].tagStore)
        XCTAssertEqual(expectedTagStore1, tagInterpreter.stringToWriteInvocations[3].tagStore)
        XCTAssertEqual(expectedTagStore1, tagInterpreter.stringToWriteInvocations[4].tagStore)
        XCTAssertEqual(expectedTagStore1, tagInterpreter.stringToWriteInvocations[5].tagStore)
        XCTAssertEqual(0, tagInterpreter.allRelevantFieldsContainExistingMetadataInvocations.count)

        let jeffTags = tagger.readTags()
        XCTAssertEqual("Jeff1", jeffTags.title)
        XCTAssertEqual("Jeff2", jeffTags.artist)
        XCTAssertEqual("Jeff3", jeffTags.album)
        XCTAssertEqual("Jeff4", jeffTags.comment)
        XCTAssertEqual("Jeff5", jeffTags.grouping)
        XCTAssertEqual("Jeff6", jeffTags.key)

        tagInterpreter.stringToWriteValues = [
            .title: "Sid1",
            .artist: "Sid2",
            .album: "Sid3",
            .comment: "Sid4",
            .grouping: "Sid5",
            // no key, just to check that nil is passed
        ]
        tagger.writeTags(key: .EMajor)

        let expectedTagStore2 = SongTagStore(
            title: "Jeff1",
            artist: "Jeff2",
            album: "Jeff3",
            comment: "Jeff4",
            grouping: "Jeff5",
            key: "Jeff6"
        )

        XCTAssertEqual(2, tagInterpreterFactoryInvocations)
        XCTAssertEqual(12, tagInterpreter.stringToWriteInvocations.count)
        XCTAssertEqual(.title, tagInterpreter.stringToWriteInvocations[6].field)
        XCTAssertEqual(.artist, tagInterpreter.stringToWriteInvocations[7].field)
        XCTAssertEqual(.album, tagInterpreter.stringToWriteInvocations[8].field)
        XCTAssertEqual(.comment, tagInterpreter.stringToWriteInvocations[9].field)
        XCTAssertEqual(.grouping, tagInterpreter.stringToWriteInvocations[10].field)
        XCTAssertEqual(.key, tagInterpreter.stringToWriteInvocations[11].field)
        XCTAssertEqual(.EMajor, tagInterpreter.stringToWriteInvocations[6].key)
        XCTAssertEqual(.EMajor, tagInterpreter.stringToWriteInvocations[7].key)
        XCTAssertEqual(.EMajor, tagInterpreter.stringToWriteInvocations[8].key)
        XCTAssertEqual(.EMajor, tagInterpreter.stringToWriteInvocations[9].key)
        XCTAssertEqual(.EMajor, tagInterpreter.stringToWriteInvocations[10].key)
        XCTAssertEqual(.EMajor, tagInterpreter.stringToWriteInvocations[11].key)
        XCTAssertEqual(expectedTagStore2, tagInterpreter.stringToWriteInvocations[6].tagStore)
        XCTAssertEqual(expectedTagStore2, tagInterpreter.stringToWriteInvocations[7].tagStore)
        XCTAssertEqual(expectedTagStore2, tagInterpreter.stringToWriteInvocations[8].tagStore)
        XCTAssertEqual(expectedTagStore2, tagInterpreter.stringToWriteInvocations[9].tagStore)
        XCTAssertEqual(expectedTagStore2, tagInterpreter.stringToWriteInvocations[10].tagStore)
        XCTAssertEqual(expectedTagStore2, tagInterpreter.stringToWriteInvocations[11].tagStore)
        XCTAssertEqual(0, tagInterpreter.allRelevantFieldsContainExistingMetadataInvocations.count)

        let sidTags = tagger.readTags()
        XCTAssertEqual("Sid1", sidTags.title)
        XCTAssertEqual("Sid2", sidTags.artist)
        XCTAssertEqual("Sid3", sidTags.album)
        XCTAssertEqual("Sid4", sidTags.comment)
        XCTAssertEqual("Sid5", sidTags.grouping)
        XCTAssertEqual("Jeff6", sidTags.key) // left over from prior value
    }
}
