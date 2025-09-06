//
//  SupportedDevicesTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation
import Testing

@testable import Visual_Minipro

struct SupportedDevicesTests {

    @Test func testSupportedLogicICsHappyPath() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut: Data("4069\n4011\n4012\n4013\n4015\n4016\n40161\n40162\n40163\n4017\n40174\n40175".utf8),
            stdErr: "")
        let supportedDevices = try SupportedDevicesProcessor.run(miniproResult)
        #expect(
            supportedDevices.logicICs == [
                "4069", "4011", "4012", "4013", "4015", "4016", "40161", "40162", "40163", "4017", "40174", "40175",
            ])
    }

    @Test func testSupportedLogicICsRemovesDuplicates() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data("4069\n4011\n4069\n4069\n4015\n4011".utf8),
            stdErr: "")
        let supportedDevices = try SupportedDevicesProcessor.run(miniproResult)
        #expect(
            supportedDevices.logicICs == ["4069", "4011", "4015"])
    }

    @Test func testSupportedEEPROMsHappyPath() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut: Data("ACE24AC08\nACE24AC08@SOIC8\nACE24AC08@TSSOP8\nACE24C08A\nACE24C08A@SOIC8".utf8),
            stdErr: "")
        let supportedDevices = try SupportedDevicesProcessor.run(miniproResult)
        #expect(
            supportedDevices.eepromICs == [
                "ACE24AC08", "ACE24AC08@SOIC8", "ACE24AC08@TSSOP8", "ACE24C08A", "ACE24C08A@SOIC8",
            ])
    }

    @Test func testSupportedEEPROMsRemovesDuplicates() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut: Data(
                "ACE24AC08\nACE24AC08@SOIC8\nACE24AC08@TSSOP8\nACE24AC08\nACE24AC08@SOIC8\nACE24AC08@TSSOP8".utf8),
            stdErr: "")
        let supportedDevices = try SupportedDevicesProcessor.run(miniproResult)
        #expect(
            supportedDevices.eepromICs == ["ACE24AC08", "ACE24AC08@SOIC8", "ACE24AC08@TSSOP8"])
    }

    @Test func testLogicICsAndEEpromsAreSeparted() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data("4069\n24C02\n4011\n24C04\n4012\n24C08\n4013\n24C16".utf8),
            stdErr: "")
        let supportedDevices = try SupportedDevicesProcessor.run(miniproResult)
        #expect(
            supportedDevices.logicICs == ["4069", "4011", "4012", "4013"])
        #expect(
            supportedDevices.eepromICs == ["24C02", "24C04", "24C08", "24C16"])
    }

    @Test func testCustomChipsAreRecognized() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut: Data(
                "7497\n8212(custom)\n(EVERSPIN)MR0A16A@SSOP44(0.8mm)\n82C55A-5(OKI)(custom)\nACE24AC04\nATF750C-TEST(custom)"
                    .utf8),
            stdErr: "")

        let supportedDevices = try SupportedDevicesProcessor.run(miniproResult)
        #expect(
            supportedDevices.logicICs == ["7497", "8212", "82C55A-5(OKI)"])
        #expect(
            supportedDevices.eepromICs == [
                "(EVERSPIN)MR0A16A@SSOP44(0.8mm)", "ACE24AC04", "ATF750C-TEST",
            ])
    }

    @Test func testChipsWithTabInTheName() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut: Data("MT28FW512ABA1LPC-0AAT&#9;(RB159)@BGA64".utf8),
            stdErr: "")

        let supportedDevices = try SupportedDevicesProcessor.run(miniproResult)
        #expect(supportedDevices.logicICs == [])
        #expect(supportedDevices.eepromICs == ["MT28FW512ABA1LPC-0AAT&#9;(RB159)@BGA64"])
    }

    @Test func testThatUnrecognizedChipsEndInBothCategories() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut: Data("ABC\n123".utf8),
            stdErr: "")

        let supportedDevices = try SupportedDevicesProcessor.run(miniproResult)
        #expect(supportedDevices.logicICs == ["ABC", "123"])
        #expect(supportedDevices.eepromICs == ["ABC", "123"])
    }

    @Test func testSupportedDeviceChecksForErrors() {
        #expect(throws: MiniproAPIError.unknownError("Error")) {
            try SupportedDevicesProcessor.run(InvocationResult(exitCode: 0, stdOut: Data(), stdErr: "Error"))
        }
    }
}
