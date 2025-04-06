//
//  ResponseProcessorUtilsTest.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Testing

@testable import MiniproUI
import Foundation

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
            try DeviceDetailsProcessor.run(
                InvocationResult(exitCode: 0, stdOut: Data(), stdErr: "Device AT45DB161D[Page512] not found!"))
        }
    }
}
