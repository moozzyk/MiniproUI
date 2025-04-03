//
//  DeviceDetailsProcessorTest.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Testing

@testable import MiniproUI
import Foundation

struct DeviceDetailsProcessorTest {
    private static let testCases: [(String, DeviceDetails)] = [
        (
            """
            Found T48 00.1.31 (0x11f)
            Warning: T48 support is experimental!
            Device code: 46A16257
            Serial code: HSSCVO9LARFMOYKYOMVE5123
            Manufactured: 2024-06-2816:55
            USB speed: 480Mbps (USB 2.0)
            Supply voltage: 5.12 V
            Name: 7404
            Package:     DIP14
            VCC voltage:     2.35V
            Vector count:     2
            """,
            DeviceDetails(
                name: "7404",
                deviceInfo: [
                    KeyValuePair(key: "Name", value: "7404"),
                    KeyValuePair(key: "Package", value: "DIP14"),
                    KeyValuePair(key: "VCC voltage", value: "2.35V"),
                    KeyValuePair(key: "Vector count", value: "2"),
                ], programmingInfo: [], isLogicChip: true)
        ),
        (
            """
            Found T48 00.1.31 (0x11f)
            Warning: T48 support is experimental!
            Device code: 46A16257
            Serial code: HSSCVO9LARFMOYKYOMVE5123
            Manufactured: 2024-06-2816:55
            USB speed: 480Mbps (USB 2.0)
            Supply voltage: 5.12 V
            Name: AM29F040B@DIP32
            Available on: TL866A/CS
            Memory: 524288 Bytes
            Package: DIP32
            ICSP: -
            Protocol: 0x06
            Read buffer size: 4096 Bytes
            Write buffer size: 256 Bytes
            """,
            DeviceDetails(
                name: "AM29F040B@DIP32",
                deviceInfo: [
                    KeyValuePair(key: "Name", value: "AM29F040B@DIP32"),
                    KeyValuePair(key: "Available on", value: "TL866A/CS"),
                    KeyValuePair(key: "Memory", value: "524288 Bytes"),
                    KeyValuePair(key: "Package", value: "DIP32"),
                    KeyValuePair(key: "ICSP", value: "-"),
                    KeyValuePair(key: "Protocol", value: "0x06"),
                    KeyValuePair(key: "Read buffer size", value: "4096 Bytes"),
                    KeyValuePair(key: "Write buffer size", value: "256 Bytes"),
                ], programmingInfo: [], isLogicChip: false)
        ),
        (
            """
            Found T48 00.1.31 (0x11f)
            Warning: T48 support is experimental!
            Device code: 46A16257
            Serial code: HSSCVO9LARFMOYKYOMVE5123
            Manufactured: 2024-06-2816:55
            USB speed: 480Mbps (USB 2.0)
            Supply voltage: 5.12 V
            Name: JS28F640P30TF@TSOP56
            Available on: TL866A/CS
            Memory: 4194304 Words + 272 Bytes
            Package: Adapter011.JPG
            ICSP: -
            Protocol: 0x12
            Read buffer size: 32768 Bytes
            Write buffer size: 2048 Bytes
            """,
            DeviceDetails(
                name: "JS28F640P30TF@TSOP56",
                deviceInfo: [
                    KeyValuePair(key: "Name", value: "JS28F640P30TF@TSOP56"),
                    KeyValuePair(key: "Available on", value: "TL866A/CS"),
                    KeyValuePair(key: "Memory", value: "4194304 Words + 272 Bytes"),
                    KeyValuePair(key: "Package", value: "Adapter011.JPG"),
                    KeyValuePair(key: "ICSP", value: "-"),
                    KeyValuePair(key: "Protocol", value: "0x12"),
                    KeyValuePair(key: "Read buffer size", value: "32768 Bytes"),
                    KeyValuePair(key: "Write buffer size", value: "2048 Bytes"),
                ], programmingInfo: [], isLogicChip: false)
        ),
        (
            """
            Found T48 00.1.31 (0x11f)
            Warning: T48 support is experimental!
            Device code: 46A16257
            Serial code: HSSCVO9LARFMOYKYOMVE5123
            Manufactured: 2024-06-2816:55
            USB speed: 480Mbps (USB 2.0)
            Supply voltage: 58.99 V
            Name: AT27LV512R@PLCC32
            Available on: TL866A/CS
            Memory: 65536 Bytes
            Package: DIP63
            ICSP: -
            Protocol: 0x0a
            Read buffer size: 1024 Bytes
            Write buffer size: 128 Bytes
            *******************************
            VPP programming voltage: 9V
            VDD write voltage: 2V
            VCC verify voltage: -V
            Pulse delay: 100us
            """,
            DeviceDetails(
                name: "AT27LV512R@PLCC32",
                deviceInfo: [
                    KeyValuePair(key: "Name", value: "AT27LV512R@PLCC32"),
                    KeyValuePair(key: "Available on", value: "TL866A/CS"),
                    KeyValuePair(key: "Memory", value: "65536 Bytes"),
                    KeyValuePair(key: "Package", value: "DIP63"),
                    KeyValuePair(key: "ICSP", value: "-"),
                    KeyValuePair(key: "Protocol", value: "0x0a"),
                    KeyValuePair(key: "Read buffer size", value: "1024 Bytes"),
                    KeyValuePair(key: "Write buffer size", value: "128 Bytes"),
                ],
                programmingInfo: [
                    KeyValuePair(key: "VPP programming voltage", value: "9V"),
                    KeyValuePair(key: "VDD write voltage", value: "2V"),
                    KeyValuePair(key: "VCC verify voltage", value: "-V"),
                    KeyValuePair(key: "Pulse delay", value: "100us"),
                ], isLogicChip: false)
        ),

    ]

    @Test(arguments: testCases)
    func testDeviceDetaislProcessorForIC(testCase: (String, DeviceDetails)) async throws {
        let (input, expectedDeviceDetails) = testCase
        let result = InvocationResult(exitCode: 0, stdOut: Data(), stdErr: input)
        let deviceDetails = try DeviceDetailsProcessor.run(result)
        #expect(deviceDetails == expectedDeviceDetails)
    }

    @Test func testDeviceDetailsProcessorThrowsForUnknownDevice() {
        #expect(throws: APIError.deviceNotFound("AT45DB161D[Page512]")) {
            try DeviceDetailsProcessor.run(
                InvocationResult(
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
                        Device AT45DB161D[Page512] not found!
                        """))
        }
    }

    @Test func testDeviceDetailsProcessorChecksForErrors() {
        #expect(throws: APIError.unknownError("Error")) {
            try DeviceDetailsProcessor.run(InvocationResult(exitCode: 0, stdOut: Data(), stdErr: "Error"))
        }
    }
}
