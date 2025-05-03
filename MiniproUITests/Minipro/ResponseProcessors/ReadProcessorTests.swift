//
//  ReadProcessorTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 4/5/25.
//

import Testing
import Foundation

@testable import MiniproUI

struct ReadProcessorTests {

    @Test func readProcessorSuccessResponse() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data("ROM Data".utf8),
            stdErr:
                "Found T48 00.1.31 (0x11f)\nWarning: T48 support is experimental!\nDevice code: 46A16257\nSerial code: HSSCVO9LARFMOYKYOMVE5123\nManufactured: 2024-06-2816:55\nUSB speed: 480Mbps (USB 2.0)\nSupply voltage: 5.13 V\nChip ID: 0xDA08  OK\n\r\u{1B}[KReading Code...   0%\r\u{1B}[KReading Code...   1%\r\u{1B}[KReading Code...   3%\r\u{1B}[KReading Code...   4%\r\u{1B}[KReading Code...   6%\r\u{1B}[KReading Code...   7%\r\u{1B}[KReading Code...   9%\r\u{1B}[KReading Code...  10%\r\u{1B}[KReading Code...  12%\r\u{1B}[KReading Code...  14%\r\u{1B}[KReading Code...  15%\r\u{1B}[KReading Code...  17%\r\u{1B}[KReading Code...  18%\r\u{1B}[KReading Code...  20%\r\u{1B}[KReading Code...  21%\r\u{1B}[KReading Code...  23%\r\u{1B}[KReading Code...  25%\r\u{1B}[KReading Code...  26%\r\u{1B}[KReading Code...  28%\r\u{1B}[KReading Code...  29%\r\u{1B}[KReading Code...  31%\r\u{1B}[KReading Code...  32%\r\u{1B}[KReading Code...  34%\r\u{1B}[KReading Code...  35%\r\u{1B}[KReading Code...  37%\r\u{1B}[KReading Code...  39%\r\u{1B}[KReading Code...  40%\r\u{1B}[KReading Code...  42%\r\u{1B}[KReading Code...  43%\r\u{1B}[KReading Code...  45%\r\u{1B}[KReading Code...  46%\r\u{1B}[KReading Code...  48%\r\u{1B}[KReading Code...  50%\r\u{1B}[KReading Code...  51%\r\u{1B}[KReading Code...  53%\r\u{1B}[KReading Code...  54%\r\u{1B}[KReading Code...  56%\r\u{1B}[KReading Code...  57%\r\u{1B}[KReading Code...  59%\r\u{1B}[KReading Code...  60%\r\u{1B}[KReading Code...  62%\r\u{1B}[KReading Code...  64%\r\u{1B}[KReading Code...  65%\r\u{1B}[KReading Code...  67%\r\u{1B}[KReading Code...  68%\r\u{1B}[KReading Code...  70%\r\u{1B}[KReading Code...  71%\r\u{1B}[KReading Code...  73%\r\u{1B}[KReading Code...  75%\r\u{1B}[KReading Code...  76%\r\u{1B}[KReading Code...  78%\r\u{1B}[KReading Code...  79%\r\u{1B}[KReading Code...  81%\r\u{1B}[KReading Code...  82%\r\u{1B}[KReading Code...  84%\r\u{1B}[KReading Code...  85%\r\u{1B}[KReading Code...  87%\r\u{1B}[KReading Code...  89%\r\u{1B}[KReading Code...  90%\r\u{1B}[KReading Code...  92%\r\u{1B}[KReading Code...  93%\r\u{1B}[KReading Code...  95%\r\u{1B}[KReading Code...  96%\r\u{1B}[KReading Code...  98%\r\u{1B}[KReading Code...  0.44Sec  OK\n"
        )

        let readResult = try ReadProcessor.run(miniproResult)
        #expect(String(data: readResult, encoding: .utf8) == "ROM Data")
    }

    @Test func readProcessorProgrammerNotFound() async throws {
        #expect(throws: MiniproAPIError.programmerNotFound) {
            try ReadProcessor.run(InvocationResult(exitCode: 1, stdOut: Data(), stdErr: "No programmer found."))
        }
    }

    @Test func readProcessorErrorExitCode() async throws {
        #expect(throws: MiniproAPIError.readError(1)) {
            try ReadProcessor.run(InvocationResult(exitCode: 1, stdOut: Data("garbage or empty".utf8), stdErr: "???"))
        }
    }

    @Test func readProcessorInvalidChip() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.13 V
                Invalid Chip ID: expected 0x89001788, got 0xFCFFFEFF (unknown)
                (use '-y' to continue anyway at your own risk)
                """
        )

        #expect(throws: MiniproAPIError.invalidChip("0x89001788", "0xFCFFFEFF")) {
            try ReadProcessor.run(miniproResult)
        }
    }

    @Test func readProcessorUnsupportedChip() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.13 V
                Unsupported device!
                """)
        #expect(throws: MiniproAPIError.unsupportedChip) {
            try ReadProcessor.run(miniproResult)
        }
    }

}
