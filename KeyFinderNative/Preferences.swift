//
//  Preferences.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 14/02/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

struct Preferences {

    var skipFilesWithExistingMetadata: Bool
    var writeAutomatically: Bool
    var skipFilesLongerThanMinutes: Int

    enum WhatToWrite: Int, Identifiable, CaseIterable, InitializableWithOptional {
        case keys
        case customCodes
        case both

        var id: WhatToWrite { self }
    }

    var whatToWrite: WhatToWrite

    enum HowToWrite: Int, Identifiable, InitializableWithOptional {
        case no
        case prepend
        case append
        case overwrite

        var id: HowToWrite { self }

        private static let unusualTags: [HowToWrite] = [.no, .prepend, .append]
        static let titleFieldOptions = unusualTags
        static let artistFieldOptions = unusualTags
        static let albumFieldOptions = unusualTags

        private static let usualTags: [HowToWrite] = [.no, .prepend, .append, .overwrite]
        static let commentFieldOptions = usualTags
        static let groupingFieldOptions = usualTags

        static let keyFieldOptions: [HowToWrite] = [.no, .overwrite]
    }

    var howToWriteToTitleField: HowToWrite
    var howToWriteToArtistField: HowToWrite
    var howToWriteToAlbumField: HowToWrite
    var howToWriteToCommentField: HowToWrite
    var howToWriteToGroupingField: HowToWrite
    var howToWriteToKeyField: HowToWrite

    var fieldDelimiter: String

    var customCodesMajor: [String]
    var customCodesMinor: [String]
    var customCodeSilence: String
}

extension Preferences {

    init(from ud: UserDefaults = .standard) {
        typealias k = Constants.UserDefaultsKeys
        typealias d = Constants.Defaults
        skipFilesWithExistingMetadata = (ud.value(forKey: k.skipFilesWithExistingMetadata) as? Bool) ?? d.skipFilesWithExistingMetadata
        skipFilesLongerThanMinutes = (ud.value(forKey: k.skipFilesLongerThanMinutes) as? Int) ?? d.skipFilesLongerThanMinutes
        writeAutomatically = (ud.value(forKey: k.writeAutomatically) as? Bool) ?? d.writeAutomatically
        whatToWrite = WhatToWrite(optionalRawValue: ud.value(forKey: k.whatToWrite) as? Int) ?? d.whatToWrite
        howToWriteToTitleField = HowToWrite(optionalRawValue: ud.value(forKey: k.howToWriteToTitleField) as? Int) ?? d.howToWriteToTitleField
        howToWriteToArtistField = HowToWrite(optionalRawValue: ud.value(forKey: k.howToWriteToArtistField) as? Int) ?? d.howToWriteToArtistField
        howToWriteToAlbumField = HowToWrite(optionalRawValue: ud.value(forKey: k.howToWriteToAlbumField) as? Int) ?? d.howToWriteToAlbumField
        howToWriteToCommentField = HowToWrite(optionalRawValue: ud.value(forKey: k.howToWriteToCommentField) as? Int) ?? d.howToWriteToCommentField
        howToWriteToGroupingField = HowToWrite(optionalRawValue: ud.value(forKey: k.howToWriteToGroupingField) as? Int) ?? d.howToWriteToGroupingField
        howToWriteToKeyField = HowToWrite(optionalRawValue: ud.value(forKey: k.howToWriteToKeyField) as? Int) ?? d.howToWriteToKeyField
        fieldDelimiter = (ud.value(forKey: k.fieldDelimiter) as? String) ?? d.fieldDelimiter
        customCodesMajor = (ud.value(forKey: k.customCodesMajor) as? [String]) ?? d.customCodesMajor
        customCodesMinor = (ud.value(forKey: k.customCodesMinor) as? [String]) ?? d.customCodesMinor
        customCodeSilence = (ud.value(forKey: k.customCodeSilence) as? String) ?? d.customCodeSilence
    }

    func save(to ud: UserDefaults = .standard) {
        typealias k = Constants.UserDefaultsKeys
        ud.setValue(skipFilesWithExistingMetadata, forKey: k.skipFilesWithExistingMetadata)
        ud.setValue(skipFilesLongerThanMinutes, forKey: k.skipFilesLongerThanMinutes)
        ud.setValue(writeAutomatically, forKey: k.writeAutomatically)
        ud.setValue(whatToWrite.rawValue, forKey: k.whatToWrite)
        ud.setValue(howToWriteToTitleField.rawValue, forKey: k.howToWriteToTitleField)
        ud.setValue(howToWriteToArtistField.rawValue, forKey: k.howToWriteToArtistField)
        ud.setValue(howToWriteToAlbumField.rawValue, forKey: k.howToWriteToAlbumField)
        ud.setValue(howToWriteToCommentField.rawValue, forKey: k.howToWriteToCommentField)
        ud.setValue(howToWriteToGroupingField.rawValue, forKey: k.howToWriteToGroupingField)
        ud.setValue(howToWriteToKeyField.rawValue, forKey: k.howToWriteToKeyField)
        ud.setValue(fieldDelimiter, forKey: k.fieldDelimiter)
        ud.setValue(customCodesMajor, forKey: k.customCodesMajor)
        ud.setValue(customCodesMinor, forKey: k.customCodesMinor)
        ud.setValue(customCodeSilence, forKey: k.customCodeSilence)
    }
}

extension Preferences.WhatToWrite: CustomStringConvertible {

    var description: String {
        switch self {
        case .keys: return "Keys"
        case .customCodes: return "Custom codes"
        case .both: return "Both"
        }
    }
}

extension Preferences.HowToWrite: CustomStringConvertible {

    var description: String {
        switch self {
        case .no: return "No"
        case .append: return "Append"
        case .prepend: return "Prepend"
        case .overwrite: return "Overwrite"
        }
    }
}

extension Preferences {

    func howToWrite(to field: SongTagField) -> Preferences.HowToWrite {
        switch field {
        case .title:    return howToWriteToTitleField
        case .artist:   return howToWriteToArtistField
        case .album:    return howToWriteToAlbumField
        case .comment:  return howToWriteToCommentField
        case .grouping: return howToWriteToGroupingField
        case .key:      return howToWriteToKeyField
        }
    }
}

extension Preferences {

    private enum Constants {

        enum UserDefaultsKeys {
            private static let prefix = "uk.co.ibrahimshaath.keyfinder."
            static let skipFilesWithExistingMetadata = "\(prefix)skipFilesWithExistingMetadata"
            static let skipFilesLongerThanMinutes = "\(prefix)skipFilesLongerThanMinutes"
            static let writeAutomatically = "\(prefix)writeAutomatically"
            static let whatToWrite = "\(prefix)whatToWrite"
            static let howToWriteToTitleField = "\(prefix)howToWriteToTitleField"
            static let howToWriteToArtistField = "\(prefix)howToWriteToArtistField"
            static let howToWriteToAlbumField = "\(prefix)howToWriteToAlbumField"
            static let howToWriteToCommentField = "\(prefix)howToWriteToCommentField"
            static let howToWriteToGroupingField = "\(prefix)howToWriteToGroupingField"
            static let howToWriteToKeyField = "\(prefix)howToWriteToKeyField"
            static let fieldDelimiter = "\(prefix)fieldDelimiter"
            static let customCodesMajor = "\(prefix)customCodesMajor"
            static let customCodesMinor = "\(prefix)customCodesMinor"
            static let customCodeSilence = "\(prefix)customCodesSilence"
        }

        enum Defaults {
            static let skipFilesWithExistingMetadata = false
            static let skipFilesLongerThanMinutes = 30
            static let writeAutomatically = false
            static let whatToWrite = WhatToWrite.keys
            static let howToWriteToTitleField = HowToWrite.no
            static let howToWriteToArtistField = HowToWrite.no
            static let howToWriteToAlbumField = HowToWrite.no
            static let howToWriteToCommentField = HowToWrite.overwrite
            static let howToWriteToGroupingField = HowToWrite.no
            static let howToWriteToKeyField = HowToWrite.no
            static let fieldDelimiter = " - "
            static let customCodesMajor = [4, 11, 6, 1, 8, 3, 10, 5, 12, 7, 2, 9].map { "\($0)d" }
            static let customCodesMinor = [1, 8, 3, 10, 5, 12, 7, 2, 9, 4, 11, 6].map { "\($0)m" }
            static let customCodeSilence = ""
        }
    }
}
