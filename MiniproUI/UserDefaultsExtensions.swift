//
//  UserDefaultsExtensions.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 10/26/25.
//

import Foundation

extension UserDefaults {
    private static let favoriteChipsKey = "favoriteChips"
    private static let libusbDebugLoggingKey = "libusbDebugLogging"
    private static let useLegacyInfoICKey = "useLegacyInfoIC"

    var favoriteChips: [String] {
        get { stringArray(forKey: UserDefaults.favoriteChipsKey) ?? [] }
        set { set(newValue, forKey: UserDefaults.favoriteChipsKey)}
    }

    var libusbDebugLogging: Bool {
        get { bool(forKey: UserDefaults.libusbDebugLoggingKey) }
        set { set(newValue, forKey: UserDefaults.libusbDebugLoggingKey) }
    }

    var useLegacyInfoIC: Bool {
        get { bool(forKey: UserDefaults.useLegacyInfoICKey) }
        set { set(newValue, forKey: UserDefaults.useLegacyInfoICKey) }
    }
}
