//
//  ProgrammerInfoProcessorTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/4/25.
//

import Testing

@testable import Visual_Minipro
import Foundation

struct ProgrammerInfoProcessorTests {
    @Test func testProgrammerInfoProcessorHappyPath() throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data(),
            stdErr:
                """
                Supported programmers: TL866A/CS, TL866II+, T48, T56
                Found T48 00.1.30 (0x11e)
                Warning: T48 support is not yet complete!
                Warning: Firmware is out of date.
                  Expected  01.1.34 (0x122)
                  Found     00.1.30 (0x11e)
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.11 V
                minipro version 0.7.4     A free and open TL866 series programmer
                Commit date:    2025-08-03 21:30:26 -0700
                Git commit:    abb7d4854bb62b4bb8b6bc13394b166ef8414f85
                Git branch:    HEAD
                Share dir:    /usr/local/share/minipro
                TL866A/CS:    14162 devices, 45 custom
                TL866II+:    29235 devices, 47 custom
                T48:        29200 devices, 0 custom
                T56:        31926 devices, 0 custom
                Logic:          283 devices, 6 custom
                """)
        let result = try ProgrammerInfoProcessor.run(miniproResult)
        #expect(result.model == "T48")
        #expect(result.firmwareVersion == "00.1.30 (0x11e)")
        #expect(result.deviceCode == "46A16257")
        #expect(result.serialNumber == "HSSCVO9LARFMOYKYOMVE5123")
        #expect(result.dateManufactured == "2024-06-28 16:55")
        #expect(result.usbSpeed == "480Mbps (USB 2.0)")
        #expect(result.supplyVoltage == "5.11 V")
        #expect(
            result.warnings == [
                "T48 support is not yet complete!",
                "Firmware is out of date. Expected 01.1.34 (0x122), Found 00.1.30 (0x11e)",
            ])
    }

    @Test func testProgrammerInfoProcessorCannotParseResponse() {
        #expect(throws: MiniproAPIError.programmerInfoUnavailable) {
            try ProgrammerInfoProcessor.run(InvocationResult(exitCode: 0, stdOut: Data(), stdErr: ""))
        }
    }

    @Test func testProgrammerInfoProcessorChecksForErrors() {
        #expect(throws: MiniproAPIError.unknownError("Error")) {
            try ProgrammerInfoProcessor.run(InvocationResult(exitCode: 0, stdOut: Data(), stdErr: "Error"))
        }
    }
}
