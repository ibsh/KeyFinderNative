//
//  SongTags.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

struct SongTags: Hashable, Equatable {
    let title: String?
    let artist: String?
    let album: String?
    let comment: String?
    let grouping: String?
    let key: String?
}

extension SongTags {

    enum Field: CaseIterable {
        case title
        case artist
        case album
        case comment
        case grouping
        case key
    }
}

extension SongTags {

    func allRelevantFieldsContainExistingMetadata(preferences: Preferences) -> Bool {
        return Field.allCases.map {
            fieldContainsExistingMetadata($0, preferences)
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

    func stringToWrite(field: SongTags.Field, key: Key, with preferences: Preferences) -> String? {
        let resultString = field.resultString(for: key, with: preferences)
        let delim = preferences.fieldDelimiter
        switch fieldContainsExistingMetadata(field, preferences) {
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
            if let title = title {
                return "\(resultString)\(delim)\(title)"
            } else {
                return resultString
            }
        case .append:
            if let title = title {
                return "\(title)\(delim)\(resultString)"
            } else {
                return resultString
            }
        case .overwrite:
            return resultString
        }
    }
}

extension SongTags {

    private enum FieldState {
        case noExistingData
        case existingData
        case irrelevant
    }

    private func fieldContainsExistingMetadata(_ field: Field, _ preferences: Preferences) -> FieldState {
        let howToWrite = preferences.howToWrite(to: field)
        let actualValue: String? = {
            switch field {
            case .title:    return title
            case .artist:   return artist
            case .album:    return album
            case .comment:  return comment
            case .grouping: return grouping
            case .key:      return key
            }
        }()
        let possibleValues = possibleValues(for: field, with: preferences)
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

    private func possibleValues(for field: Field, with preferences: Preferences) -> [String] {
        return Key.allCases.compactMap { key in
            if key == .silence { return nil }
            return field.resultString(for: key, with: preferences)
        }
    }
}

extension SongTags.Field {

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
        return key.resultString(shortField: shortField, with: preferences)
    }
}
