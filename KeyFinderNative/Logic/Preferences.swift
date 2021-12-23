//
//  Preferences.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 14/02/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

protocol InitializableWithOptional {
    associatedtype T
    init?(maybeRawValue: T?)
}

extension InitializableWithOptional where Self: RawRepresentable {
    init?(maybeRawValue: RawValue?) {
        guard let rawValue = maybeRawValue else { return nil }
        self.init(rawValue: rawValue)
    }
}

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
        static let titleTagOptions = unusualTags
        static let artistTagOptions = unusualTags
        static let albumTagOptions = unusualTags

        private static let usualTags: [HowToWrite] = [.no, .prepend, .append, .overwrite]
        static let commentTagOptions = usualTags
        static let groupingTagOptions = usualTags

        static let keyTagOptions: [HowToWrite] = [.no, .overwrite]
    }

    var howToWriteToTitleTag: HowToWrite
    var howToWriteToArtistTag: HowToWrite
    var howToWriteToAlbumTag: HowToWrite
    var howToWriteToCommentTag: HowToWrite
    var howToWriteToGroupingTag: HowToWrite
    var howToWriteToKeyTag: HowToWrite

    var tagDelimiter: String

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
        whatToWrite = WhatToWrite(maybeRawValue: ud.value(forKey: k.whatToWrite) as? Int) ?? d.whatToWrite
        howToWriteToTitleTag = HowToWrite(maybeRawValue: ud.value(forKey: k.howToWriteToTitleTag) as? Int) ?? d.howToWriteToTitleTag
        howToWriteToArtistTag = HowToWrite(maybeRawValue: ud.value(forKey: k.howToWriteToArtistTag) as? Int) ?? d.howToWriteToArtistTag
        howToWriteToAlbumTag = HowToWrite(maybeRawValue: ud.value(forKey: k.howToWriteToAlbumTag) as? Int) ?? d.howToWriteToAlbumTag
        howToWriteToCommentTag = HowToWrite(maybeRawValue: ud.value(forKey: k.howToWriteToCommentTag) as? Int) ?? d.howToWriteToCommentTag
        howToWriteToGroupingTag = HowToWrite(maybeRawValue: ud.value(forKey: k.howToWriteToGroupingTag) as? Int) ?? d.howToWriteToGroupingTag
        howToWriteToKeyTag = HowToWrite(maybeRawValue: ud.value(forKey: k.howToWriteToKeyTag) as? Int) ?? d.howToWriteToKeyTag
        tagDelimiter = (ud.value(forKey: k.tagDelimiter) as? String) ?? d.tagDelimiter
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
        ud.setValue(howToWriteToTitleTag.rawValue, forKey: k.howToWriteToTitleTag)
        ud.setValue(howToWriteToArtistTag.rawValue, forKey: k.howToWriteToArtistTag)
        ud.setValue(howToWriteToAlbumTag.rawValue, forKey: k.howToWriteToAlbumTag)
        ud.setValue(howToWriteToCommentTag.rawValue, forKey: k.howToWriteToCommentTag)
        ud.setValue(howToWriteToGroupingTag.rawValue, forKey: k.howToWriteToGroupingTag)
        ud.setValue(howToWriteToKeyTag.rawValue, forKey: k.howToWriteToKeyTag)
        ud.setValue(tagDelimiter, forKey: k.tagDelimiter)
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

private extension Preferences {

    enum Constants {

        enum UserDefaultsKeys {
            private static let prefix = "uk.co.ibrahimshaath.keyfinder."
            static let skipFilesWithExistingMetadata = "\(prefix)skipFilesWithExistingMetadata"
            static let skipFilesLongerThanMinutes = "\(prefix)skipFilesLongerThanMinutes"
            static let writeAutomatically = "\(prefix)writeAutomatically"
            static let whatToWrite = "\(prefix)whatToWrite"
            static let howToWriteToTitleTag = "\(prefix)howToWriteToTitleTag"
            static let howToWriteToArtistTag = "\(prefix)howToWriteToArtistTag"
            static let howToWriteToAlbumTag = "\(prefix)howToWriteToAlbumTag"
            static let howToWriteToCommentTag = "\(prefix)howToWriteToCommentTag"
            static let howToWriteToGroupingTag = "\(prefix)howToWriteToGroupingTag"
            static let howToWriteToKeyTag = "\(prefix)howToWriteToKeyTag"
            static let tagDelimiter = "\(prefix)tagDelimiter"
            static let customCodesMajor = "\(prefix)customCodesMajor"
            static let customCodesMinor = "\(prefix)customCodesMinor"
            static let customCodeSilence = "\(prefix)customCodesSilence"
        }

        enum Defaults {
            static let skipFilesWithExistingMetadata = false
            static let skipFilesLongerThanMinutes = 30
            static let writeAutomatically = false
            static let whatToWrite = WhatToWrite.keys
            static let howToWriteToTitleTag = HowToWrite.no
            static let howToWriteToArtistTag = HowToWrite.no
            static let howToWriteToAlbumTag = HowToWrite.no
            static let howToWriteToCommentTag = HowToWrite.overwrite
            static let howToWriteToGroupingTag = HowToWrite.no
            static let howToWriteToKeyTag = HowToWrite.no
            static let tagDelimiter = " - "
            static let customCodesMajor = [4, 11, 6, 1, 8, 3, 10, 5, 12, 7, 2, 9].map { "\($0)d" }
            static let customCodesMinor = [1, 8, 3, 10, 5, 12, 7, 2, 9, 4, 11, 6].map { "\($0)m" }
            static let customCodeSilence = ""
        }
    }
}
