//
//  SongTagInterpreterSpy.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 05/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
@testable import KeyFinder

final class SongTagInterpreterSpy: SongTagInterpreting {

    init(preferences: Preferences) {}

    private(set) var stringToWriteInvocations = [(field: SongTagField, key: Key, tagStore: SongTagStore)]()
    var stringToWriteValues = [SongTagField: String]()
    func stringToWrite(field: SongTagField, key: Key, tagStore: SongTagStore) -> String? {
        stringToWriteInvocations.append((field: field, key: key, tagStore: tagStore))
        return stringToWriteValues[field]
    }

    private(set) var allRelevantFieldsContainExistingMetadataInvocations = [(SongTagStore)]()
    var allRelevantFieldsContainExistingMetadataValue: Bool = false
    func allRelevantFieldsContainExistingMetadata(tagStore: SongTagStore) -> Bool {
        allRelevantFieldsContainExistingMetadataInvocations.append(tagStore)
        return allRelevantFieldsContainExistingMetadataValue
    }
}
