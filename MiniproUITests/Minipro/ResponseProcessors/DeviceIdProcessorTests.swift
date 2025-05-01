//
//  ReadDeviceIdProcessorTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 4/30/25.
//

import Testing
import Foundation

@testable import MiniproUI

struct DeviceIdProcessorTests {

    @Test func readDeviceIdSuccessfulResponse() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.13 V
                Chip ID: 0xDA08  OK
                """
        )
        #expect(try DeviceIdProcessor.run(miniproResult) == "0xDA08")
    }

    @Test func readDeviceIdChipMismatchResponse() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.12 V
                Chip ID mismatch: expected 0x97D6, got 0xF8FF (unknown)
                """
        )
        #expect(throws: MiniproAPIError.chipIdMismatch("0x97D6", "0xF8FF")) {
            try DeviceIdProcessor.run(miniproResult)
        }
    }
}
