//
//  PreferencesStoring.swift
//  KeyFinderNativeTests
//
//  Created by Ibrahim Sha'ath on 06/01/2022.
//  Copyright © 2022 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

protocol PreferencesStoring {

    func value(forKey key: String) -> Any?
    func setValue(_ value: Any?, forKey key: String)
}

extension UserDefaults: PreferencesStoring { }
