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
        let deviceDetails = try await MiniproAPI.getDeviceDetails(device: "SMJ27C010A@TSOP32")
        #expect(deviceDetails.deviceInfo.count >= 4)
        #expect(deviceDetails.programmingInfo.count > 0)
    }

    @Test func testTestLogicIC() async throws {
        let logicICTestResult = try await MiniproAPI.testLogicIC(device: "7400")
        #expect(logicICTestResult.device == "7400")
        #expect(logicICTestResult.isSuccess || logicICTestResult.numErrors > 0)
        #expect(logicICTestResult.testVectors.count == 4)
    }
}
