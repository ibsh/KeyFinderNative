//
//  SongTagInterpreter.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 05/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

typealias SongTagInterpreterFactory = (
    _ preferences: Preferences
) -> SongTagInterpreting

protocol SongTagInterpreting {

    init(
        preferences: Preferences
    )

    func stringToWrite(field: SongTagField, key: Key, tagStore: SongTagStore) -> String?

    func allRelevantFieldsContainExistingMetadata(tagStore: SongTagStore) -> Bool
}

final class SongTagInterpreter: SongTagInterpreting {

    private let preferences: Preferences

    init(
        preferences: Preferences
    ) {
        self.preferences = preferences
    }

    func stringToWrite(field: SongTagField, key: Key, tagStore: SongTagStore) -> String? {
        let resultString = field.resultString(for: key, with: preferences)
        let delim = preferences.fieldDelimiter
        switch fieldContainsExistingMetadata(field, in: tagStore) {
        case .noExistingData:
            break
        case .existingData,
             .irrelevant:
            return nil
        }
        switch preferences.howToWrite(to: field) {
        case .no:
            return nil
        case .prepend:
            if let existingValue = tagStore.value(for: field) {
                return "\(resultString)\(delim)\(existingValue)"
            } else {
                return resultString
            }
        case .append:
            if let existingValue = tagStore.value(for: field) {
                return "\(existingValue)\(delim)\(resultString)"
            } else {
                return resultString
            }
        case .overwrite:
            return resultString
        }
    }

    func allRelevantFieldsContainExistingMetadata(tagStore: SongTagStore) -> Bool {
        return SongTagField.allCases.map {
            fieldContainsExistingMetadata($0, in: tagStore)
        }
        .compactMap {
            switch $0 {
            case .noExistingData: return false
            case .existingData: return true
            case .irrelevant: return nil
            }
        }
        .allSatisfy { $0 }
    }
}

extension SongTagInterpreter {

    private enum FieldState {
        case noExistingData
        case existingData
        case irrelevant
    }

    private func fieldContainsExistingMetadata(_ field: SongTagField, in tagStore: SongTagStore) -> FieldState {
        let howToWrite = preferences.howToWrite(to: field)
        let actualValue: String? = tagStore.value(for: field)
        let possibleValues = possibleValues(for: field)
        switch (howToWrite, actualValue) {
        case (.no, _):
            return .irrelevant
        case (.prepend, .some(let value)):
            let result = possibleValues.first(where: { value.hasPrefix($0) })
            return result == nil ? .noExistingData : .existingData
        case (.append, .some(let value)):
            let result = possibleValues.first(where: { value.hasSuffix($0) })
            return result == nil ? .noExistingData : .existingData
        case (.overwrite, .some(let value)):
            let result = possibleValues
                .map { field == .key ? String($0.prefix(3)) : $0 }
                .first(where: { value == $0 })
            return result == nil ? .noExistingData : .existingData
        case (_, .none):
            return .noExistingData
        }
    }

    private func possibleValues(for field: SongTagField) -> [String] {
        return Key.allCases.compactMap { key in
            if key == .silence { return nil }
            return field.resultString(for: key, with: preferences)
        }
    }
}

extension SongTagStore {

    func value(for field: SongTagField) -> String? {
        switch field {
        case .title:    return title
        case .artist:   return artist
        case .album:    return album
        case .comment:  return comment
        case .grouping: return grouping
        case .key:      return key
        }
    }
}

extension SongTagField {

    fileprivate func resultString(for key: Key, with preferences: Preferences) -> String {
        let shortField: Bool = {
            switch self {
            case .title,
                 .artist,
                 .album,
                 .comment,
                 .grouping:
                return false
            case .key:
                return true
            }
        }()
        return key.displayString(shortField: shortField, with: preferences)
    }
}
