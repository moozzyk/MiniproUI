//
//  DeviceDetailsProcessorTest.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Testing

@testable import MiniproUI

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
                deviceInfo: [
                    ("Name", "7404"),
                    ("Package", "DIP14"),
                    ("VCC voltage", "2.35V"),
                    ("Vector count", "2"),
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
                deviceInfo: [
                    ("Name", "AM29F040B@DIP32"),
                    ("Available on", "TL866A/CS"),
                    ("Memory", "524288 Bytes"),
                    ("Package", "DIP32"),
                    ("ICSP", "-"),
                    ("Protocol", "0x06"),
                    ("Read buffer size", "4096 Bytes"),
                    ("Write buffer size", "256 Bytes"),
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
                deviceInfo: [
                    ("Name", "JS28F640P30TF@TSOP56"),
                    ("Available on", "TL866A/CS"),
                    ("Memory", "4194304 Words + 272 Bytes"),
                    ("Package", "Adapter011.JPG"),
                    ("ICSP", "-"),
                    ("Protocol", "0x12"),
                    ("Read buffer size", "32768 Bytes"),
                    ("Write buffer size", "2048 Bytes"),
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
                deviceInfo: [
                    ("Name", "AT27LV512R@PLCC32"),
                    ("Available on", "TL866A/CS"),
                    ("Memory", "65536 Bytes"),
                    ("Package", "DIP63"),
                    ("ICSP", "-"),
                    ("Protocol", "0x0a"),
                    ("Read buffer size", "1024 Bytes"),
                    ("Write buffer size", "128 Bytes"),
                ],
                programmingInfo: [
                    ("VPP programming voltage", "9V"),
                    ("VDD write voltage", "2V"),
                    ("VCC verify voltage", "-V"),
                    ("Pulse delay", "100us"),
                ], isLogicChip: false)
        ),

    ]

    func deviceDetailsEqual(_ device1: DeviceDetails, _ device2: DeviceDetails) -> Bool {
        let areEqual: ([(String, String)], [(String, String)]) -> Bool = { (lhs, rhs) in
            lhs.count == rhs.count
                && zip(lhs, rhs).allSatisfy { (lhs, rhs) in
                    lhs == rhs
                }
        }

        return areEqual(device1.deviceInfo, device2.deviceInfo)
            && areEqual(device1.programmingInfo, device2.programmingInfo)
            && device1.isLogicChip == device2.isLogicChip
    }

    @Test(arguments: testCases)
    func testDeviceDetaislProcessorForIC(testCase: (String, DeviceDetails)) async throws {
        let (input, expectedDeviceDetails) = testCase
        let result = InvocationResult(exitCode: 0, stdOut: "", stdErr: input)
        let deviceDetails = try DeviceDetailsProcessor.run(result)
        #expect(deviceDetailsEqual(deviceDetails, expectedDeviceDetails))
    }

    @Test func testDeviceDetailsProcessorThrowsForUnknownDevice() {
        #expect(throws: APIError.deviceNotFound("AT45DB161D[Page512]")) {
            try DeviceDetailsProcessor.run(
                InvocationResult(
                    exitCode: 0, stdOut: "",
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

    @Test func testDeviceDetailsProcessorChecksForError() {
        #expect(throws: APIError.unknownError("Error")) {
            try DeviceDetailsProcessor.run(InvocationResult(exitCode: 0, stdOut: "", stdErr: "Error"))
        }
    }
}
