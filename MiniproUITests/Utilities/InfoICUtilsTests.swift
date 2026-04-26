//
//  InfoICUtilsTests.swift
//  MiniproUITests
//

import Testing
import Foundation

@testable import Visual_Minipro

@Suite(.serialized)
struct InfoICUtilsTests {
    @Test func returnsLegacyInfoICForNonT76WhenToggleEnabled() {
        let original = UserDefaults.standard.useLegacyInfoIC
        defer { UserDefaults.standard.useLegacyInfoIC = original }
        UserDefaults.standard.useLegacyInfoIC = true

        #expect(InfoICUtils.resolveInfoICPath(for: .t48).lastPathComponent == "infoic_0.7.4.xml")
    }

    @Test func returnsDefaultInfoICForT76WhenToggleEnabled() {
        let original = UserDefaults.standard.useLegacyInfoIC
        defer { UserDefaults.standard.useLegacyInfoIC = original }
        UserDefaults.standard.useLegacyInfoIC = true

        #expect(InfoICUtils.resolveInfoICPath(for: .t76).lastPathComponent == "infoic.xml")
    }

    @Test func returnsDefaultInfoICWhenToggleDisabled() {
        let original = UserDefaults.standard.useLegacyInfoIC
        defer { UserDefaults.standard.useLegacyInfoIC = original }
        UserDefaults.standard.useLegacyInfoIC = false

        #expect(InfoICUtils.resolveInfoICPath(for: .t48).lastPathComponent == "infoic.xml")
    }
}
