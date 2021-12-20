//
//  Constants.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 01/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

enum Constants {

    static let semitones = 12 // per octave, obviously
    static let octaves = octaveWeights.count
    static let bands = semitones * octaves
    static let toneProfileSize = bands * 2

    static let fftFrameSize = 16384
    static let hopSize = fftFrameSize / 4

    static let directSKStretch: Float = 0.8

    static let downsampledFrameRate = 4410

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

    static let frequencies: [Float] = [
        32.7031956625748,
        34.647828872109,
        36.708095989676,
        38.8908729652601,
        41.2034446141088,
        43.6535289291255,
        46.2493028389543,
        48.9994294977187,
        51.9130871974932,
        55,
        58.2704701897613,
        61.7354126570155,
        65.4063913251497,
        69.2956577442181,
        73.4161919793519,
        77.7817459305203,
        82.4068892282175,
        87.307057858251,
        92.4986056779087,
        97.9988589954374,
        103.826174394986,
        110,
        116.540940379523,
        123.470825314031,
        130.812782650299,
        138.591315488436,
        146.832383958704,
        155.563491861041,
        164.813778456435,
        174.614115716502,
        184.997211355817,
        195.997717990875,
        207.652348789973,
        220,
        233.081880759045,
        246.941650628062,
        261.625565300599,
        277.182630976872,
        293.664767917408,
        311.126983722081,
        329.62755691287,
        349.228231433004,
        369.994422711635,
        391.99543598175,
        415.304697579946,
        440.000000000001,
        466.163761518091,
        493.883301256125,
        523.251130601198,
        554.365261953745,
        587.329535834816,
        622.253967444163,
        659.255113825741,
        698.456462866009,
        739.98884542327,
        783.9908719635,
        830.609395159892,
        880.000000000002,
        932.327523036182,
        987.76660251225,
        1046.5022612024,
        1108.73052390749,
        1174.65907166963,
        1244.50793488833,
        1318.51022765148,
        1396.91292573202,
        1479.97769084654,
        1567.981743927,
        1661.21879031978,
        1760,
        1864.65504607236,
        1975.5332050245,
    ]

    private static let majorProfileOctave: [Float] = [
        7.23900502618145225142,
        3.50351166725158691406,
        3.58445177536649417505,
        2.84511816478676315967,
        5.81898892118549859731,
        4.55865057415321039969,
        2.44778850545506543313,
        6.99473192146829525484,
        3.39106613673504853068,
        4.55614256655143456953,
        4.07392666663523606019,
        4.45932757378886890365,
    ]

    private static let minorProfileOctave: [Float] = [
        7.00255045060284420089,
        3.14360279015996679775,
        4.35904319714962529275,
        5.40418120718934069657,
        3.67234420879306133756,
        4.08971184917797891956,
        3.90791435991553992579,
        6.19960288562316463867,
        3.63424625625277419871,
        2.87241191079875557435,
        5.35467999794542670600,
        3.83242038595048351013,
    ]

    private static let octaveWeights: [Float] = [
        0.39997267549999998559,
        0.55634425248300645173,
        0.52496636345143543600,
        0.60847548384277727607,
        0.59898115679999996974,
        0.49072435317960994006,
    ]

    static let majorProfile: [Float] = {
        var profile = [Float]()
        for o in octaveWeights {
            for s in majorProfileOctave {
                profile.append(o * s)
            }
        }
        return profile
    }()

    static let minorProfile: [Float] = {
        var profile = [Float]()
        for o in octaveWeights {
            for s in minorProfileOctave {
                profile.append(o * s)
            }
        }
        return profile
    }()

    enum TagIDs {

        enum id3 {
            static let title = "id3/tit2"
            static let artist = "id3/tpe1"
            static let album = "id3/talb"
            static let comment = "id3/comm"
            static let grouping = "id3/tit1"
            static let key = "id3/tkey"
        }

        enum iTunes {
            static let title = "itsk/%A9nam"
            static let artist = "itsk/%a9art"
            static let album = "itsk/%a9alb"
            static let comment = "itsk/%a9cmt"
            static let grouping = "itsk/%a9grp"
            static let key = "itlk/com.apple.itunes.initialkey"
        }
    }

    static let parallelTagReaders = 10
}

extension Constants.Key {

    private var defaultString: String {
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

    func displayString(preferences: Preferences) -> String {
        switch preferences.whatToWrite {
        case .keys:
            return defaultString
        case .customCodes:
            return customCode(preferences: preferences)
        case .both:
            return "\(customCode(preferences: preferences)) \(defaultString)"
        }
    }
}
