//
//  ConstantsTests.swift
//  KeyFinderTests
//
//  Created by Ibrahim Sha'ath on 06/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import XCTest
@testable import KeyFinder

// swiftlint:disable type_body_length
final class ConstantsTests: XCTestCase {

    func testPrimitiveConstantsDontChange() {
        XCTAssertEqual(12, Constants.Analysis.semitones)
        XCTAssertEqual(16384, Constants.Analysis.fftFrameSize)
        XCTAssertEqual(0.8, Constants.Analysis.directSKStretch, accuracy: 0.000001)
        XCTAssertEqual(4410, Constants.Analysis.downsampledFrameRate)
    }

    func testDerivedConstantsDontChange() {
        XCTAssertEqual(6, Constants.Analysis.octaves)
        XCTAssertEqual(72, Constants.Analysis.bands)
        XCTAssertEqual(4096, Constants.Analysis.hopSize)
    }

    func testFrequenciesDontChange() {
        let expectations: [Float] = [
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
        XCTAssertEqual(expectations.count, Constants.Analysis.frequencies.count)
        for (i, expectedValue) in expectations.enumerated() {
            XCTAssertEqual(
                expectedValue,
                Constants.Analysis.frequencies[i],
                accuracy: 0.000001,
                "Invalid frequency at \(i)"
            )
        }
    }

    func testMajorProfileDoesntChange() {
        let expectations: [Float] = [
            2.8954043,
            1.4013089,
            1.4336827,
            1.1379695,
            2.3274364,
            1.8233356,
            0.9790485,
            2.7977016,
            1.3563337,
            1.8223325,
            1.6294593,
            1.7836093,
            4.027379,
            1.9491587,
            1.9941891,
            1.5828651,
            3.2373612,
            2.536179,
            1.3618131,
            3.891479,
            1.8866001,
            2.5347836,
            2.2665057,
            2.4809215,
            3.800234,
            1.8392258,
            1.8817165,
            1.4935913,
            3.0547733,
            2.3931382,
            1.2850066,
            3.671999,
            1.7801956,
            2.3918214,
            2.1386743,
            2.340997,
            4.4047575,
            2.1318011,
            2.181051,
            1.7311846,
            3.540712,
            2.773827,
            1.4894193,
            4.256123,
            2.0633807,
            2.772301,
            2.4788845,
            2.7133918,
            4.3360276,
            2.0985374,
            2.147019,
            1.704172,
            3.4854646,
            2.7305458,
            1.4661791,
            4.1897125,
            2.0311847,
            2.7290432,
            2.440205,
            2.6710532,
            3.552356,
            1.7192585,
            1.7589778,
            1.3961687,
            2.8555195,
            2.2370408,
            1.2011894,
            3.4324853,
            1.6640787,
            2.23581,
            1.999175,
            2.1883006,
        ]
        XCTAssertEqual(expectations.count, Constants.Analysis.majorProfile.count)
        for (i, expectedValue) in expectations.enumerated() {
            XCTAssertEqual(
                expectedValue,
                Constants.Analysis.majorProfile[i],
                accuracy: 0.000001,
                "Invalid frequency at \(i)"
            )
        }
    }

    func testMinorProfileDoesntChange() {
        let expectations: [Float] = [
            2.800829,
            1.2573552,
            1.7434982,
            2.1615248,
            1.4688374,
            1.635773,
            1.563059,
            2.479672,
            1.4535992,
            1.1488863,
            2.1417258,
            1.5328634,
            3.895829,
            1.7489254,
            2.4251287,
            3.0065851,
            2.0430877,
            2.2752876,
            2.1741457,
            3.4491136,
            2.021892,
            1.59805,
            2.9790456,
            2.1321452,
            3.6761036,
            1.6502857,
            2.288351,
            2.8370132,
            1.9278572,
            2.146961,
            2.0515237,
            3.2545831,
            1.9078571,
            1.5079197,
            2.8110268,
            2.0118918,
            4.2608805,
            1.9128053,
            2.652371,
            3.2883117,
            2.2345314,
            2.4884894,
            2.37787,
            3.7723067,
            2.21135,
            1.7477924,
            3.2581916,
            2.331934,
            4.1943955,
            1.8829588,
            2.6109846,
            3.2370026,
            2.1996648,
            2.44966,
            2.3407671,
            3.7134454,
            2.176845,
            1.7205206,
            3.2073524,
            2.2955475,
            3.4363222,
            1.5426425,
            2.1390886,
            2.6519632,
            1.8021088,
            2.006921,
            1.9177088,
            3.0422962,
            1.7834132,
            1.4095625,
            2.627672,
            1.880662,
        ]
        XCTAssertEqual(expectations.count, Constants.Analysis.minorProfile.count)
        for (i, expectedValue) in expectations.enumerated() {
            XCTAssertEqual(
                expectedValue,
                Constants.Analysis.minorProfile[i],
                accuracy: 0.000001,
                "Invalid frequency at \(i)"
            )
        }
    }
}
