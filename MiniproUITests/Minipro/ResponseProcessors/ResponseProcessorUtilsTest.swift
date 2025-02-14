//
//  ResponseProcessorUtilsTest.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Testing

@testable import MiniproUI

struct ResponseProcessorUtilsTest {

    @Test func testEnsureNoErrorThrowsIfProgrammerNotConnected() {
        #expect(throws: APIError.programmerNotFound) {
            try ensureNoError(
                invocationResult: InvocationResult(exitCode: 1, stdOut: "", stdErr: "No programmer found.\n"))
        }
    }

    @Test func testEnsureNoErrorProcessorThrowsOnErrors() {
        #expect(throws: APIError.unknownError("Error: something went wrong.")) {
            try ensureNoError(
                invocationResult:
                    InvocationResult(exitCode: 1, stdOut: "", stdErr: "Error: something went wrong.\n"))
        }
    }

    @Test func testEnsureNoErrorThrowsWhenForIncorrectDevicee() {
        #expect(throws: APIError.deviceNotFound("AT45DB161D[Page512]")) {
            try DeviceDetailsProcessor.run(
                InvocationResult(exitCode: 0, stdOut: "", stdErr: "Device AT45DB161D[Page512] not found!"))
        }
    }
}
