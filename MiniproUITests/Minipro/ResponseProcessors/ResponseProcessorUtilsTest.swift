//
//  ResponseProcessorUtilsTest.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation
import Testing

@testable import MiniproUI

struct ResponseProcessorUtilsTest {

    @Test func testEnsureNoErrorThrowsIfProgrammerNotConnected() {
        #expect(throws: MiniproAPIError.programmerNotFound) {
            try ensureNoError(
                invocationResult: InvocationResult(exitCode: 1, stdOut: Data(), stdErr: "No programmer found.\n"))
        }
    }

    @Test func testEnsureNoErrorProcessorThrowsOnErrors() {
        #expect(throws: MiniproAPIError.unknownError("Error: something went wrong.")) {
            try ensureNoError(
                invocationResult:
                    InvocationResult(exitCode: 1, stdOut: Data(), stdErr: "Error: something went wrong.\n"))
        }
    }

    @Test func testEnsureNoErrorThrowsWhenForIncorrectDevicee() {
        #expect(throws: MiniproAPIError.deviceNotFound("AT45DB161D[Page512]")) {
            try ensureNoError(
                invocationResult:
                    InvocationResult(exitCode: 0, stdOut: Data(), stdErr: "Device AT45DB161D[Page512] not found!"))
        }
    }

    // Happens randomly when using FEMC004GTTG7-T24-10_8Bit@BGA153 as a device with w27c512@DIP8 chip
    @Test func testIOError() {
        #expect(throws: MiniproAPIError.ioError("bulk_transfer: LIBUSB_ERROR_TIMEOUT")) {
            try ensureNoError(
                invocationResult: InvocationResult(
                    exitCode: 1, stdOut: Data(),
                    stdErr:
                        """
                        Found T48 00.1.31 (0x11f)
                        Warning: T48 support is experimental!
                        Device code: 46A16257
                        Serial code: HSSCVO9LARFMOYKYOMVE5123
                        Manufactured: 2024-06-2816:55
                        USB speed: 480Mbps (USB 2.0)
                        Supply voltage: 5.13 V
                        {1b}[KReading Code...   0%
                        IO error: bulk_transfer: LIBUSB_ERROR_TIMEOUT
                        """))
        }

    }

    // Happens randomly when using FEMC004GTTG7-T24-10_8Bit@BGA153 as a device with w27c512@DIP8 chip
    @Test func testIOError2() {
        #expect(
            throws: MiniproAPIError.ioError(
                "bulk_transfer: LIBUSB_ERROR_TIMEOUT\nexpected 5 bytes but 0 bytes transferred")
        ) {
            try ensureNoError(
                invocationResult: InvocationResult(
                    exitCode: 1, stdOut: Data(),
                    stdErr:
                        """
                        IO error: bulk_transfer: LIBUSB_ERROR_TIMEOUT
                        IO error: expected 5 bytes but 0 bytes transferred
                        """))
        }

    }
}
