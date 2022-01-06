//
//  KeyTests.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 06/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import XCTest
@testable import KeyFinder

final class KeyTests: XCTestCase {

    private var preferences: Preferences!

    override func setUp() {
        preferences = Preferences()
        preferences.customCodesMajor = [
            "four dee",
            "eleven dee",
            "six dee",
            "one dee",
            "eight dee",
            "three dee",
            "ten dee",
            "five dee",
            "twelve dee",
            "seven dee",
            "two dee",
            "nine dee",
        ]
        preferences.customCodesMinor = [
            "one em",
            "eight em",
            "three em",
            "ten em",
            "five em",
            "twelve em",
            "seven em",
            "two em",
            "nine em",
            "four em",
            "eleven em",
            "six em",
        ]
        preferences.customCodeSilence = "silence"
    }

    func testDisplayStringWritingKeysAndLongFields() {

        let expectations = [
            "A", "Am",
            "Bb", "Bbm",
            "B", "Bm",
            "C", "Cm",
            "Db", "Dbm",
            "D", "Dm",
            "Eb", "Ebm",
            "E", "Em",
            "F", "Fm",
            "Gb", "Gbm",
            "G", "Gm",
            "Ab", "Abm",
            "",
        ]

        preferences.whatToWrite = .keys

        let actuals = Key.allCases.map {
            $0.displayString(shortField: false, with: preferences)
        }

        XCTAssertEqual(expectations, actuals)
    }

    func testDisplayStringWritingKeysAndShortFields() {

        let expectations = [
            "A", "Am",
            "Bb", "Bbm",
            "B", "Bm",
            "C", "Cm",
            "Db", "Dbm",
            "D", "Dm",
            "Eb", "Ebm",
            "E", "Em",
            "F", "Fm",
            "Gb", "Gbm",
            "G", "Gm",
            "Ab", "Abm",
            "",
        ]

        preferences.whatToWrite = .keys

        let actuals = Key.allCases.map {
            $0.displayString(shortField: true, with: preferences)
        }

        XCTAssertEqual(expectations, actuals)
    }

    func testDisplayStringWritingCustomAndLongFields() {

        let expectations = [
            "four dee", "one em",
            "eleven dee", "eight em",
            "six dee", "three em",
            "one dee", "ten em",
            "eight dee", "five em",
            "three dee", "twelve em",
            "ten dee", "seven em",
            "five dee", "two em",
            "twelve dee", "nine em",
            "seven dee", "four em",
            "two dee", "eleven em",
            "nine dee", "six em",
            "silence",
        ]

        preferences.whatToWrite = .customCodes

        let actuals = Key.allCases.map {
            $0.displayString(shortField: false, with: preferences)
        }

        XCTAssertEqual(expectations, actuals)
    }

    func testDisplayStringWritingCustomAndShortFields() {

        let expectations = [
            "fou", "one",
            "ele", "eig",
            "six", "thr",
            "one", "ten",
            "eig", "fiv",
            "thr", "twe",
            "ten", "sev",
            "fiv", "two",
            "twe", "nin",
            "sev", "fou",
            "two", "ele",
            "nin", "six",
            "sil",
        ]

        preferences.whatToWrite = .customCodes

        let actuals = Key.allCases.map {
            $0.displayString(shortField: true, with: preferences)
        }

        XCTAssertEqual(expectations, actuals)
    }

    func testDisplayStringWritingBothAndLongFields() {

        let expectations = [
            "four dee A", "one em Am",
            "eleven dee Bb", "eight em Bbm",
            "six dee B", "three em Bm",
            "one dee C", "ten em Cm",
            "eight dee Db", "five em Dbm",
            "three dee D", "twelve em Dm",
            "ten dee Eb", "seven em Ebm",
            "five dee E", "two em Em",
            "twelve dee F", "nine em Fm",
            "seven dee Gb", "four em Gbm",
            "two dee G", "eleven em Gm",
            "nine dee Ab", "six em Abm",
            "silence",
        ]

        preferences.whatToWrite = .both

        let actuals = Key.allCases.map {
            $0.displayString(shortField: false, with: preferences)
        }

        XCTAssertEqual(expectations, actuals)
    }

    func testDisplayStringWritingBothAndShortFields() {

        preferences.customCodesMajor = [
            "4d",
            "11d",
            "6d",
            "1d",
            "8d",
            "3d",
            "10d",
            "5d",
            "12d",
            "7d",
            "2s",
            "9d",
        ]
        preferences.customCodesMinor = [
            "1m",
            "8m",
            "3m",
            "10m",
            "5m",
            "12m",
            "7m",
            "2m",
            "9m",
            "4m",
            "11m",
            "6m",
        ]
        preferences.customCodeSilence = "🐈‍⬛"

        let expectations = [
            "4d", "1m",
            "11d", "8m",
            "6d", "3m",
            "1d", "10m",
            "8d", "5m",
            "3d", "12m",
            "10d", "7m",
            "5d", "2m",
            "12d", "9m",
            "7d", "4m",
            "2s", "11m",
            "9d", "6m",
            "🐈‍⬛",
        ]

        preferences.whatToWrite = .both

        let actuals = Key.allCases.map {
            $0.displayString(shortField: true, with: preferences)
        }

        XCTAssertEqual(expectations, actuals)
    }
}
