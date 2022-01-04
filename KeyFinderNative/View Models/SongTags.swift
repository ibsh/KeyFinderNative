//
//  SongTags.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

struct SongTags {
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

    enum FieldState {
        case noExistingData
        case existingData
        case irrelevant
    }

    func titleFieldContainsExistingMetadata(_ preferences: Preferences) -> FieldState {
        return fieldContainsExistingMetadata(.title, preferences)
    }

    func artistFieldContainsExistingMetadata(_ preferences: Preferences) -> FieldState {
        return fieldContainsExistingMetadata(.artist, preferences)
    }

    func albumFieldContainsExistingMetadata(_ preferences: Preferences) -> FieldState {
        return fieldContainsExistingMetadata(.album, preferences)
    }

    func commentFieldContainsExistingMetadata(_ preferences: Preferences) -> FieldState {
        return fieldContainsExistingMetadata(.comment, preferences)
    }

    func groupingFieldContainsExistingMetadata(_ preferences: Preferences) -> FieldState {
        return fieldContainsExistingMetadata(.grouping, preferences)
    }

    func keyFieldContainsExistingMetadata(_ preferences: Preferences) -> FieldState {
        return fieldContainsExistingMetadata(.key, preferences)
    }

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

    func value(of field: Field) -> String? {
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

private extension SongTags {

    func fieldContainsExistingMetadata(_ field: Field, _ preferences: Preferences) -> FieldState {
        let howToWrite = preferences.howToWrite(to: field)
        let value = value(of: field)
        let valuesToCheck = valuesToCheck(for: field, with: preferences)
        switch (howToWrite, value) {
        case (.no, _):
            return .irrelevant
        case (.prepend, .some(let value)):
            let result = valuesToCheck.first(where: { value.hasPrefix($0) })
            return result == nil ? .noExistingData : .existingData
        case (.append, .some(let value)):
            let result = valuesToCheck.first(where: { value.hasSuffix($0) })
            return result == nil ? .noExistingData : .existingData
        case (.overwrite, .some(let value)):
            let result = valuesToCheck
                .map { field == .key ? String($0.prefix(3)) : $0 }
                .first(where: { value == $0 })
            return result == nil ? .noExistingData : .existingData
        case (_, .none):
            return .noExistingData
        }
    }

    func valuesToCheck(for field: Field, with preferences: Preferences) -> [String] {
        return Constants.Key.allCases.compactMap { key in
            if key == .silence { return nil }
            return key.resultString(for: field, with: preferences)
        }
    }
}
