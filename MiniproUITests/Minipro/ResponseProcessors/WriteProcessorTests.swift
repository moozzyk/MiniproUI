//
//  WriteProcessorTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 5/1/25.
//

import Foundation
import Testing

@testable import MiniproUI

struct WriteProcessorTests {

    @Test func writePorcessorSuccessuflResponse() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                "Found T48 00.1.31 (0x11f)\nWarning: T48 support is experimental!\nDevice code: 46A16257\nSerial code: HSSCVO9LARFMOYKYOMVE5123\nManufactured: 2024-06-2816:55\nUSB speed: 480Mbps (USB 2.0)\nSupply voltage: 5.13 V\nChip ID: 0xDA08  OK\nWarning: Incorrect file size: 1024 (needed 65536)\nErasing... 0.30Sec OK\n\r\u{1b}[KWriting  Code...   0%\r\u{1b}[KWriting  Code...  12%\r\u{1b}[KWriting  Code...  25%\r\u{1b}[KWriting  Code...  37%\r\u{1b}[KWriting  Code...  50%\r\u{1b}[KWriting  Code...  62%\r\u{1b}[KWriting  Code...  75%\r\u{1b}[KWriting  Code...  87%\r\u{1b}[KWriting Code...  0.35Sec  OK\n\r\u{1b}[KReading Code...   0%\r\u{1b}[KReading Code...  0.01Sec  OK\nVerification OK\n"
        )

        #expect(throws: Never.self) {
            try WriteProcessor.run(miniproResult)
        }
    }

    @Test func writePorcessorIncorrectFileSize() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.12 V
                Incorrect file size: 32768 (needed 512, use -s/S to ignore)
                """
        )

        #expect(throws: MiniproAPIError.incorrectFileSize(512, 32768)) {
            try WriteProcessor.run(miniproResult)
        }
    }

    @Test func writeProcessorInvalidChipId() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.12 V

                VPP=-V, VDD=2.1V, VCC=-V, Pulse=100us
                Invalid Chip ID: expected 0x97D6, got 0xF8FF (unknown)
                (use '-y' to continue anyway at your own risk)
                """)

        #expect(throws: MiniproAPIError.invalidChip("0x97D6", "0xF8FF")) {
            try WriteProcessor.run(miniproResult)
        }
    }

    @Test func writeProcessorOvercurrentProtection() async throws {
        // When trying to program a Logic Chip
        let miniproResult = InvocationResult(
            exitCode: 1,
            stdOut:
                Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.12 V
                WARNING: Chip ID mismatch: expected 0xDA08, got 0xFFFF (unknown)
                Erasing... 0.30Sec OK
                Writing  Code...   0%
                Overcurrent protection!
                """)

        #expect(throws: MiniproAPIError.unknownError("Overcurrent protection! Exit code: 1")) {
            try WriteProcessor.run(miniproResult)
        }
    }
}
