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
        let result = try await MiniproAPI.getProgrammerInfo()
        #expect(result.model == "T48")
        #expect(!result.firmwareVersion.isEmpty)
        #expect(!result.deviceCode.isEmpty)
        #expect(!result.serialNumber.isEmpty)
        #expect(!result.dateManufactured.isEmpty)
        #expect(!result.usbSpeed.isEmpty)
        #expect(!result.supplyVoltage.isEmpty)
    }

    @Test func testGetSupportedDevices() async throws {
        let result = try await MiniproAPI.getSupportedDevices()
        #expect(result.count > 1000)
        #expect(result.contains("AM29F040B@DIP32"))
        #expect(result.count == Set(result).count)
    }

    @Test func testGetDevicesDetials() async throws {
        let result = try await MiniproAPI.getDeviceDetails(device: "AM29F040B@DIP32")
        #expect(result.count > 10)
    }
}
