//
//  ResponseProcessorUtilsTest.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Testing

@testable import MiniproUI

struct ResponseProcessorUtilsTest {

    @Test func testProgrammerInfoProcessorThrowsIfProgrammerNotConnected() {
        #expect(throws: APIError.programmerNotFound) {
            try ensureNoError(invocationResult: InvocationResult(exitCode: 1, stdOut: "", stdErr: "No programmer found.\n"))
        }
    }

    @Test func testProgrammerInfoProcessorThrowsOnErrors() {
        #expect(throws: APIError.unknownError("Error: something went wrong.")) {
            try ensureNoError(invocationResult:
                InvocationResult(exitCode: 1, stdOut: "", stdErr: "Error: something went wrong.\n"))
        }
    }
}
