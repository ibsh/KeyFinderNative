//
//  Key.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 03/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

enum Key: CaseIterable {
    case AMajor
    case AMinor
    case BFlatMajor
    case BFlatMinor
    case BMajor
    case BMinor
    case CMajor
    case CMinor
    case DFlatMajor
    case DFlatMinor
    case DMajor
    case DMinor
    case EFlatMajor
    case EFlatMinor
    case EMajor
    case EMinor
    case FMajor
    case FMinor
    case GFlatMajor
    case GFlatMinor
    case GMajor
    case GMinor
    case AFlatMajor
    case AFlatMinor
    case silence
}

extension Key {

    func displayString(field: SongTagField, with preferences: Preferences) -> String {
        return displayString(shortField: field.isShort, with: preferences)
    }

    func displayString(shortField: Bool, with preferences: Preferences) -> String {
        let resultString: String = {
            switch preferences.whatToWrite {
            case .keys:
                return keyString
            case .customCodes:
                return customCode(preferences: preferences)
            case .both:
                return "\(customCode(preferences: preferences)) \(keyString)"
            }
        }()
        let output = shortField ? String(resultString.prefix(3)) : resultString
        return output.trimmingCharacters(in: .whitespaces)
    }

    private var keyString: String {
        switch self {
        case .AMajor:     return "A"
        case .AMinor:     return "Am"
        case .BFlatMajor: return "Bb"
        case .BFlatMinor: return "Bbm"
        case .BMajor:     return "B"
        case .BMinor:     return "Bm"
        case .CMajor:     return "C"
        case .CMinor:     return "Cm"
        case .DFlatMajor: return "Db"
        case .DFlatMinor: return "Dbm"
        case .DMajor:     return "D"
        case .DMinor:     return "Dm"
        case .EFlatMajor: return "Eb"
        case .EFlatMinor: return "Ebm"
        case .EMajor:     return "E"
        case .EMinor:     return "Em"
        case .FMajor:     return "F"
        case .FMinor:     return "Fm"
        case .GFlatMajor: return "Gb"
        case .GFlatMinor: return "Gbm"
        case .GMajor:     return "G"
        case .GMinor:     return "Gm"
        case .AFlatMajor: return "Ab"
        case .AFlatMinor: return "Abm"
        case .silence:    return String()
        }
    }

    private func customCode(preferences: Preferences) -> String {
        switch self {
        case .AMajor:     return preferences.customCodesMajor[0]
        case .AMinor:     return preferences.customCodesMinor[0]
        case .BFlatMajor: return preferences.customCodesMajor[1]
        case .BFlatMinor: return preferences.customCodesMinor[1]
        case .BMajor:     return preferences.customCodesMajor[2]
        case .BMinor:     return preferences.customCodesMinor[2]
        case .CMajor:     return preferences.customCodesMajor[3]
        case .CMinor:     return preferences.customCodesMinor[3]
        case .DFlatMajor: return preferences.customCodesMajor[4]
        case .DFlatMinor: return preferences.customCodesMinor[4]
        case .DMajor:     return preferences.customCodesMajor[5]
        case .DMinor:     return preferences.customCodesMinor[5]
        case .EFlatMajor: return preferences.customCodesMajor[6]
        case .EFlatMinor: return preferences.customCodesMinor[6]
        case .EMajor:     return preferences.customCodesMajor[7]
        case .EMinor:     return preferences.customCodesMinor[7]
        case .FMajor:     return preferences.customCodesMajor[8]
        case .FMinor:     return preferences.customCodesMinor[8]
        case .GFlatMajor: return preferences.customCodesMajor[9]
        case .GFlatMinor: return preferences.customCodesMinor[9]
        case .GMajor:     return preferences.customCodesMajor[10]
        case .GMinor:     return preferences.customCodesMinor[10]
        case .AFlatMajor: return preferences.customCodesMajor[11]
        case .AFlatMinor: return preferences.customCodesMinor[11]
        case .silence:    return preferences.customCodeSilence
        }
    }
}
