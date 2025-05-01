//
//  MiniproAPITests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/3/25.
//

import Testing

@testable import MiniproUI

struct MiniproAPITests {
    @Sendable static func isW27C512Present() async throws -> Bool {
        return (try? await MiniproAPI.readDeviceId(device: "W27C512@DIP28")) == "0xDA08"
    }

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

    @Test(.enabled("W27512 not present", isW27C512Present))
    func testReadDeviceIdReturnsDeviceId() async throws {
        let deviceId = try? await MiniproAPI.readDeviceId(device: "W27C512@DIP28")
        #expect(deviceId == "0xDA08")
    }

    @Test(.enabled("W27512 not present", isW27C512Present))
    func testReadDeviceIdThrowsForChipMismatch() async throws {
        await #expect(
            throws: MiniproAPIError.chipIdMismatch("0x97D6", "0xF8FF")
        ) {
            try await MiniproAPI.readDeviceId(device: "SMJ27C010A@TSOP32")
        }
    }
}
