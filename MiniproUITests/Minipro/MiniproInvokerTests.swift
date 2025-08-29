//
//  MiniproInvokerTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/3/25.
//

import Testing

@testable import Visual_Minipro

struct MiniproInvokerTests {
    @Test func testInvokeNoError() async throws {
        let result = try await MiniproInvoker.invoke(arguments: ["-k"])
        #expect(result.exitCode == 0)
        #expect(result.stdErr == "t48: T48\n")
        #expect(result.stdOutString == "")
    }

    @Test func testInvokeError() async throws {
        let result = try await MiniproInvoker.invoke(arguments: ["-p"])
        #expect(result.exitCode == 1)
        #expect(result.stdErr.contains("minipro: option requires an argument -- p"))
        #expect(result.stdOutString == "")
    }
}
