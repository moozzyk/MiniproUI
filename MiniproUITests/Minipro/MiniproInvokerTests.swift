//
//  MiniproInvokerTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/3/25.
//

import Testing
@testable import MiniproUI

struct MiniproInvokerTests {
    @Test func testInvokeNoError() throws {
        let result = try MiniproInvoker.invoke(arguments: ["-k"])
         #expect(result.exitCode == 0)
         #expect(result.stdErr == "t48: T48\n")
         #expect(result.stdOut ==  "")
    }

    @Test func testInvokeError() throws {
        let result = try MiniproInvoker.invoke(arguments: ["-p"])
         #expect(result.exitCode == 1)
         #expect(result.stdErr.contains("minipro: option requires an argument -- p"))
         #expect(result.stdOut ==  "")
    }
}
