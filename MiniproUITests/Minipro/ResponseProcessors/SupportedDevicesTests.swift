//
//  SupportedDevicesTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Testing

@testable import Visual_Minipro
import Foundation

struct SupportedDevicesTests {

    @Test func testSupportedDevicesHappyPath() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data("4069\n4011\n4012\n4013\n4015\n4016\n40161\n40162\n40163\n4017\n40174\n40175".utf8),
            stdErr: "")
        let supportedDevices = try SupportedDevicesProcessor.run(miniproResult)
        #expect(
            supportedDevices == [
                "4069", "4011", "4012", "4013", "4015", "4016", "40161", "40162", "40163", "4017", "40174", "40175",
            ])
    }

    @Test func testSupportedDevicesRemovesDuplicates() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data("4069\n4011\n4069\n4069\n4015\n4011".utf8),
            stdErr: "")
        let supportedDevices = try SupportedDevicesProcessor.run(miniproResult)
        #expect(
            supportedDevices == ["4069", "4011", "4015"])
    }

    @Test func testSupportedDeviceChecksForErrors() {
        #expect(throws: MiniproAPIError.unknownError("Error")) {
            try SupportedDevicesProcessor.run(InvocationResult(exitCode: 0, stdOut: Data(), stdErr: "Error"))
        }
    }
}
