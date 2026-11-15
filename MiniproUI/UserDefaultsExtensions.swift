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
    private static let reviewPeriodStartKey = "reviewPeriodStart"
    private static let successfulOperationCountKey = "successfulOperationCount"

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

    var reviewPeriodStart: Date? {
        get { object(forKey: UserDefaults.reviewPeriodStartKey) as? Date }
        set { set(newValue, forKey: UserDefaults.reviewPeriodStartKey) }
    }

    var successfulOperationCount: Int {
        get { integer(forKey: UserDefaults.successfulOperationCountKey) }
        set { set(newValue, forKey: UserDefaults.successfulOperationCountKey) }
    }

    func getInstalledSoftwareBundle(for programmerModel: ProgrammerModel) -> String? {
        string(forKey: "\(programmerModel.rawValue)_bundle")
    }

    func setInstalledSoftwareBundle(_ bundleName: String, for programmerModel: ProgrammerModel) {
        set(bundleName, forKey: "\(programmerModel.rawValue)_bundle")
    }
}
