//
//  SongTagInterpreter.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 05/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

typealias SongTagInterpreterFactory = (
    _ preferences: Preferences
) -> SongTagInterpreting

protocol SongTagInterpreting {

    init(preferences: Preferences)

    func stringToWrite(field: SongTagField, key: Key, tagStore: SongTagStore) -> String?

    func allRelevantFieldsContainExistingMetadata(tagStore: SongTagStore) -> Bool
}

final class SongTagInterpreter: SongTagInterpreting {

    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    func stringToWrite(field: SongTagField, key: Key, tagStore: SongTagStore) -> String? {
        let resultString = key.displayString(field: field, with: preferences)
        let delimiter = preferences.fieldDelimiter
        switch preferences.howToWrite(to: field) {
        case .no:
            return nil
        case .prepend:
            if let existingValue = tagStore.value(for: field),
               existingValue.trimmingCharacters(in: .whitespaces).isEmpty == false {
                if existingValue == resultString || existingValue.hasPrefix(resultString + delimiter) {
                    return nil
                }
                return "\(resultString)\(delimiter)\(existingValue)"
            } else {
                return resultString
            }
        case .append:
            if let existingValue = tagStore.value(for: field),
               existingValue.trimmingCharacters(in: .whitespaces).isEmpty == false {
                if existingValue == resultString || existingValue.hasSuffix(delimiter + resultString) {
                    return nil
                }
                return "\(existingValue)\(delimiter)\(resultString)"
            } else {
                return resultString
            }
        case .overwrite:
            if let existingValue = tagStore.value(for: field),
               existingValue == resultString {
                return nil
            }
            return resultString
        }
    }

    func allRelevantFieldsContainExistingMetadata(tagStore: SongTagStore) -> Bool {
        let responses: [Bool] = SongTagField.allCases.compactMap { field in
            let howToWrite = preferences.howToWrite(to: field)
            let actualValue: String? = tagStore.value(for: field)
            let possibleValues = possibleValues(for: field)
            let delimiter = preferences.fieldDelimiter
            switch (howToWrite, actualValue) {
            case (.no, _):
                return nil
            case (.prepend, .some(let value)):
                let result = possibleValues.first(where: { value == $0 || value.hasPrefix($0 + delimiter) })
                return result != nil
            case (.append, .some(let value)):
                let result = possibleValues.first(where: { value == $0 || value.hasSuffix(delimiter + $0) })
                return result != nil
            case (.overwrite, .some(let value)):
                let result = possibleValues.first(where: { value == $0 })
                return result != nil
            case (_, .none):
                return false
            }
        }
        return responses.isEmpty == false && responses.allSatisfy { $0 }
    }
}

extension SongTagInterpreter {

    private func possibleValues(for field: SongTagField) -> [String] {
        return Key.allCases.compactMap { key in
            if key == .silence { return nil }
            return key.displayString(field: field, with: preferences)
        }
    }
}
