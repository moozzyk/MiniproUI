//
//  UserDefaultsExtensions.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 10/26/25.
//

import Foundation

extension UserDefaults {
    private static let favoriteChipsKey = "favoriteChips"

    var favoriteChips: [String] {
        get { stringArray(forKey: UserDefaults.favoriteChipsKey) ?? [] }
        set { set(newValue, forKey: UserDefaults.favoriteChipsKey)}
    }
}
