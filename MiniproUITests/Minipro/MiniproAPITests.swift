//
//  MiniproAPITests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/3/25.
//

import Testing

@testable import MiniproUI

struct MiniproAPITests {
    @Test func testGetProgrammerInfo() async throws {
        let result = try MiniproAPI.getProgrammerInfo()
        #expect(result.model == "T48")
        #expect(!result.firmwareVersion.isEmpty)
        #expect(!result.deviceCode.isEmpty)
        #expect(!result.serialNumber.isEmpty)
        #expect(!result.dateManufactured.isEmpty)
        #expect(!result.usbSpeed.isEmpty)
        #expect(!result.supplyVoltage.isEmpty)
    }
}
