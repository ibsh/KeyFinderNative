//
//  FakePreferencesStorage.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 06/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation
@testable import KeyFinder

final class FakePreferencesStorage: PreferencesStoring {

    private var values = [String: Any]()

    func value(forKey key: String) -> Any? {
        return values[key]
    }

    func setValue(_ value: Any?, forKey key: String) {
        values[key] = value
    }
}
