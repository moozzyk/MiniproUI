//
//  UpdateFirmwareProcessorTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 5/18/25.
//

import Foundation
import Testing

@testable import MiniproUI

struct UpdateFirmwareProcessorTests {

    @Test func updateFirmwareSuccessResponse() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut: Data(),
            stdErr:
                "Found T48 00.1.17 (0x111)\nWarning: T48 support is experimental!\nWarning: Firmware is out of date.\n  Expected  01.1.31 (0x11f)\n  Found     00.1.17 (0x111)\nDevice code: 46A16257\nSerial code: HSSCVO9LARFMOYKYOMVE5123\nManufactured: 2024-06-2816:55\nUSB speed: 480Mbps (USB 2.0)\nSupply voltage: 5.12 V\n/Users/moozzyk/source/minipro-firmware/t48/t48-1.1.30.dat contains firmware version 00.1.30 (newer)\n\nDo you want to continue with firmware update? y/n:Switching to bootloader... OK\nErasing... OK\nReflashing... \r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...   99%\r\u{1b}[KReflashing... 99%\r\u{1b}[KReflashing... 99%\r\u{1b}[KReflashing... 100%\nResetting device... OK\nReflash... OK\n"
        )
        #expect(throws: Never.self) {
            try UpdateFirmwareProcessor.run(miniproResult)
        }
    }

    private func prepareInvocationResult(errorMessage: String) -> InvocationResult {
        InvocationResult(
            exitCode: 1,
            stdOut: Data(),
            stdErr:
                """
                Found T48 00.1.30 (0x11e)
                Warning: T48 support is experimental!
                Warning: Firmware is out of date.
                  Expected  01.1.31 (0x11f)
                  Found     00.1.30 (0x11e)
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.13 V
                \(errorMessage)
                """
        )
    }

    @Test func updateFirmwareFailureResponse() async throws {
        let errorMessages = [
            "../minipro-firmware/t56/t56-1 open error!: No such file or directory",
            "../minipro-corrupted.dat file size error!",
            "../minipro-firmware file read error!",
            "../minipro-firmware/tl866iiplus/tl866ii-4.2.120.dat file version error!",
            "../minipro-firmware/tl866iiplus/tl866ii-4.2.120.dat file CRC error!",
            "Erase failed!",
            "Reflash... Failed"
        ]
        for error in errorMessages {
            #expect(throws:  MiniproAPIError.firmwareUpdateError(error)) {
                let invocationResult = prepareInvocationResult(errorMessage: error)
                try UpdateFirmwareProcessor.run(invocationResult)
            }
        }
    }
}
