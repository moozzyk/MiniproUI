//
//  LogicICTestProcessorTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/13/25.
//

import Foundation
import Testing

@testable import Visual_Minipro

struct LogicICTestProcessorTests {

    @Test func testLogicICTestProcessorSuccessResponse() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(
                    """
                          1  2  3  4  5  6  7  8  9  10 11 12 13 14 
                    0000: \u{1B}[0m0  \u{1B}[0m0  \u{1B}[0mH  \u{1B}[0m0  \u{1B}[0m0  \u{1B}[0mH  \u{1B}[0mG  \u{1B}[0mH  \u{1B}[0m0  \u{1B}[0m0  \u{1B}[0mH  \u{1B}[0m0  \u{1B}[0m0  \u{1B}[0mV  \u{1B}[0m
                    0001: \u{1B}[0m1  \u{1B}[0m0  \u{1B}[0mH  \u{1B}[0m1  \u{1B}[0m0  \u{1B}[0mH  \u{1B}[0mG  \u{1B}[0mH  \u{1B}[0m1  \u{1B}[0m0  \u{1B}[0mH  \u{1B}[0m1  \u{1B}[0m0  \u{1B}[0mV  \u{1B}[0m
                    0002: \u{1B}[0m0  \u{1B}[0m1  \u{1B}[0mH  \u{1B}[0m0  \u{1B}[0m1  \u{1B}[0mH  \u{1B}[0mG  \u{1B}[0mH  \u{1B}[0m0  \u{1B}[0m1  \u{1B}[0mH  \u{1B}[0m0  \u{1B}[0m1  \u{1B}[0mV  \u{1B}[0m
                    0003: \u{1B}[0m1  \u{1B}[0m1  \u{1B}[0mL  \u{1B}[0m1  \u{1B}[0m1  \u{1B}[0mL  \u{1B}[0mG  \u{1B}[0mL  \u{1B}[0m1  \u{1B}[0m1  \u{1B}[0mL  \u{1B}[0m1  \u{1B}[0m1  \u{1B}[0mV  \u{1B}[0m
                    """.utf8),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.10 V
                Logic test successful.
                """)

        let expectedResult = LogicICTestResult(
            device: "7400",
            numErrors: 0,
            testVectors: [
                ["0", "0", "H", "0", "0", "H", "G", "H", "0", "0", "H", "0", "0", "V"],
                ["1", "0", "H", "1", "0", "H", "G", "H", "1", "0", "H", "1", "0", "V"],
                ["0", "1", "H", "0", "1", "H", "G", "H", "0", "1", "H", "0", "1", "V"],
                ["1", "1", "L", "1", "1", "L", "G", "L", "1", "1", "L", "1", "1", "V"],
            ]
        )

        let logicICTestResult = try LogicICTestProcessor.run(miniproResult, device: "7400")
        #expect(logicICTestResult.isSuccess)
        #expect(logicICTestResult == expectedResult)
    }

    @Test func testLogicICTestProcessorErrorResponse() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut: Data(
                """
                      1  2  3  4  5  6  7  8  9  10 11 12 13 14 
                0000: \u{1B}[0m0  \u{1B}[0;91mH- \u{1B}[0m0  \u{1B}[0;91mH- \u{1B}[0m0  \u{1B}[0mH  \u{1B}[0mG  \u{1B}[0mH  \u{1B}[0m0  \u{1B}[0;91mH- \u{1B}[0m0  \u{1B}[0;91mH- \u{1B}[0m0  \u{1B}[0mV  \u{1B}[0m
                0001: \u{1B}[0m1  \u{1B}[0;91mL- \u{1B}[0m1  \u{1B}[0;91mL- \u{1B}[0m1  \u{1B}[0;91mL- \u{1B}[0mG  \u{1B}[0;91mL- \u{1B}[0m1  \u{1B}[0;91mL- \u{1B}[0m1  \u{1B}[0;91mL- \u{1B}[0m1  \u{1B}[0mV  \u{1B}[0m
                """.utf8),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.10 V
                Logic test failed: 10 errors encountered.
                """)

        let expectedResult = LogicICTestResult(
            device: "7414",
            numErrors: 10,
            testVectors: [
                ["0", "H-", "0", "H-", "0", "H", "G", "H", "0", "H-", "0", "H-", "0", "V"],
                ["1", "L-", "1", "L-", "1", "L-", "G", "L-", "1", "L-", "1", "L-", "1", "V"],
            ]
        )

        let logicICTestResult = try LogicICTestProcessor.run(miniproResult, device: "7414")
        #expect(!logicICTestResult.isSuccess)
        #expect(logicICTestResult == expectedResult)
    }

    @Test func testLogicICTestProcessorChecksForErrors() {
        #expect(throws: MiniproAPIError.unknownError("Error")) {
            try LogicICTestProcessor.run(InvocationResult(exitCode: 0, stdOut: Data(), stdErr: "Error"), device: "7400")
        }
    }
}
