//
//  ProgrammerInfoProcessorTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/4/25.
//

import Testing

@testable import MiniproUI
import Foundation

struct ProgrammerInfoProcessorTests {
    @Test func testProgrammerInfoProcessorHappyPath() throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Warning: Firmware is out of date.
                  Expected  01.1.31 (0x11f)
                  Found     00.1.03 (0x103)
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.11 V
                T48: hardware_check not implemented
                """)
        let result = try ProgrammerInfoProcessor.run(miniproResult)
        #expect(result.model == "T48")
        #expect(result.firmwareVersion == "00.1.31 (0x11f)")
        #expect(result.deviceCode == "46A16257")
        #expect(result.serialNumber == "HSSCVO9LARFMOYKYOMVE5123")
        #expect(result.dateManufactured == "2024-06-28 16:55")
        #expect(result.usbSpeed == "480Mbps (USB 2.0)")
        #expect(result.supplyVoltage == "5.11 V")
        #expect(
            result.warnings == [
                "T48 support is experimental!",
                "Firmware is out of date. Expected 01.1.31 (0x11f), Found 00.1.03 (0x103)",
            ])
    }

    @Test func testProgrammerInfoProcessorCannotParseResponse() {
        #expect(throws: APIError.programmerInfoUnavailable) {
            try ProgrammerInfoProcessor.run(InvocationResult(exitCode: 0, stdOut: Data(), stdErr: ""))
        }
    }

    @Test func testProgrammerInfoProcessorChecksForErrors() {
        #expect(throws: APIError.unknownError("Error")) {
            try ProgrammerInfoProcessor.run(InvocationResult(exitCode: 0, stdOut: Data(), stdErr: "Error"))
        }
    }
}
