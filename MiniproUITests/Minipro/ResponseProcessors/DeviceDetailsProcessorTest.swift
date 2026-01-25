//
//  DeviceDetailsProcessorTest.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation
import Testing

@testable import Visual_Minipro

struct DeviceDetailsProcessorTest {
    private static let testCases: [(String, DeviceDetails)] = [
        (
            """
            Found T48 00.1.35 (0x123)
            Warning: T48 support is not yet complete!
            Device code: 46A16257
            Serial code: HSSCVO9LARFMOYKYOMVE5123
            Manufactured: 2024-06-2816:55
            USB speed: 480Mbps (USB 2.0)
            Supply voltage: 58.99 V

            ---------------Chip Info----------------
            Name: 7404
            Package:     DIP14
            Vector count:     2
            ----------------------------------------
            Default VCC voltage: 5 V
            Available VCC voltages [V]: 1.8, 2.5,
            3.3, 5
            """,
            DeviceDetails(
                name: "7404",
                deviceInfo: [
                    KeyValuePair(key: "Name", value: "7404"),
                    KeyValuePair(key: "Package", value: "DIP14"),
                    KeyValuePair(key: "Default VCC voltage", value: "5 V"),
                    KeyValuePair(key: "Vector count", value: "2"),
                ], programmingInfo: [], isLogicChip: true)
        ),
        (
            """
            Found T48 00.1.35 (0x123)
            Warning: T48 support is not yet complete!
            Device code: 46A16257
            Serial code: HSSCVO9LARFMOYKYOMVE5123
            Manufactured: 2024-06-2816:55
            USB speed: 480Mbps (USB 2.0)
            Supply voltage: 58.99 V

            ---------------Chip Info----------------
            Name: AM29F040B@DIP32
            Available on: TL866II, T48, T56
            Memory: 524288 Bytes
            Package: DIP32
            Protocol: 0x06
            Read buffer size: 4096 Bytes
            Write buffer size: 256 Bytes
            ----------------------------------------
            """,
            DeviceDetails(
                name: "AM29F040B@DIP32",
                deviceInfo: [
                    KeyValuePair(key: "Name", value: "AM29F040B@DIP32"),
                    KeyValuePair(key: "Available on", value: "TL866II, T48, T56"),
                    KeyValuePair(key: "Memory", value: "524288 Bytes"),
                    KeyValuePair(key: "Package", value: "DIP32"),
                    KeyValuePair(key: "Protocol", value: "0x06"),
                    KeyValuePair(key: "Read buffer size", value: "4096 Bytes"),
                    KeyValuePair(key: "Write buffer size", value: "256 Bytes"),
                ], programmingInfo: [], isLogicChip: false)
        ),
        (
            """
            Found T48 00.1.35 (0x123)
            Warning: T48 support is not yet complete!
            Device code: 46A16257
            Serial code: HSSCVO9LARFMOYKYOMVE5123
            Manufactured: 2024-06-2816:55
            USB speed: 480Mbps (USB 2.0)
            Supply voltage: 58.99 V

            ---------------Chip Info----------------
            Name: JS28F640P30TF@TSOP56
            Available on: T48, T56
            Memory: 4194304 Words + 272 Bytes
            Package: Adapter011.JPG
            Read buffer size: 32768 Bytes
            Write buffer size: 2048 Bytes
            ----------------------------------------
            """,
            DeviceDetails(
                name: "JS28F640P30TF@TSOP56",
                deviceInfo: [
                    KeyValuePair(key: "Name", value: "JS28F640P30TF@TSOP56"),
                    KeyValuePair(key: "Available on", value: "T48, T56"),
                    KeyValuePair(key: "Memory", value: "4194304 Words + 272 Bytes"),
                    KeyValuePair(key: "Package", value: "Adapter011.JPG"),
                    KeyValuePair(key: "Read buffer size", value: "32768 Bytes"),
                    KeyValuePair(key: "Write buffer size", value: "2048 Bytes"),
                ], programmingInfo: [], isLogicChip: false)
        ),
        (
            """
            Found T48 00.1.35 (0x123)
            Warning: T48 support is not yet complete!
            Device code: 46A16257
            Serial code: HSSCVO9LARFMOYKYOMVE5123
            Manufactured: 2024-06-2816:55
            USB speed: 480Mbps (USB 2.0)
            Supply voltage: 58.99 V

            ---------------Chip Info----------------
            Name: AT27LV512R@PLCC32
            Available on: TL866II, T48, T56
            Memory: 65536 Bytes
            Package: PLCC32
            Protocol: 0x0a
            Read buffer size: 1024 Bytes
            Write buffer size: 128 Bytes
            ----------------------------------------
            Default VPP programming voltage: 12 V
            Available VPP voltages [V]: 9, 9.5, 10,
            11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5,
            15.5, 16, 16.5, 17, 18, 21, 25

            Default VDD write voltage: 5.5 V
            Available VDD write voltages [V]: 1.2,
            1.8, 2.5, 3, 3.3, 4, 4.5, 4.75, 5,
            5.25, 5.5, 5.75, 6, 6.25, 6.5

            Default VCC verify voltage: 5 V
            Available VCC verify voltages [V]: 1.2,
            1.8, 2.5, 3, 3.3, 4, 4.5, 4.75, 5,
            5.25, 5.5, 5.75, 6, 6.25, 6.5

            Default write pulse: 100 us
            Available write pulse[us]: 1-65535
            ----------------------------------------
            """,
            DeviceDetails(
                name: "AT27LV512R@PLCC32",
                deviceInfo: [
                    KeyValuePair(key: "Name", value: "AT27LV512R@PLCC32"),
                    KeyValuePair(key: "Available on", value: "TL866II, T48, T56"),
                    KeyValuePair(key: "Memory", value: "65536 Bytes"),
                    KeyValuePair(key: "Package", value: "PLCC32"),
                    KeyValuePair(key: "Protocol", value: "0x0a"),
                    KeyValuePair(key: "Read buffer size", value: "1024 Bytes"),
                    KeyValuePair(key: "Write buffer size", value: "128 Bytes"),
                ],
                programmingInfo: [
                    KeyValuePair(key: "Default VPP programming voltage", value: "12 V"),
                    KeyValuePair(key: "Default VDD write voltage", value: "5.5 V"),
                    KeyValuePair(key: "Default VCC verify voltage", value: "5 V"),
                    KeyValuePair(key: "Default write pulse", value: "100 us"),
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
        #expect(throws: MiniproAPIError.deviceNotFound("AT45DB161D[Page512]")) {
            try DeviceDetailsProcessor.run(
                InvocationResult(
                    exitCode: 0, stdOut: Data(),
                    stdErr:
                        """
                        Found T48 00.1.35 (0x123)
                        Warning: T48 support is not yet complete!
                        Device code: 46A16257
                        Serial code: HSSCVO9LARFMOYKYOMVE5123
                        Manufactured: 2024-06-2816:55
                        USB speed: 480Mbps (USB 2.0)
                        Supply voltage: 58.99 V

                        Device AT45DB161D[Page512] not found!
                        """))
        }
    }

    @Test func testDeviceDetailsProcessorChecksForErrors() {
        #expect(throws: MiniproAPIError.unknownError("Error")) {
            try DeviceDetailsProcessor.run(InvocationResult(exitCode: 0, stdOut: Data(), stdErr: "Error"))
        }
    }
}
