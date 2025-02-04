//
//  MiniproInvokerTest.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 2/3/25.
//

import XCTest
@testable import MiniproUI

final class MiniproInvokerTest: XCTestCase {

    func testInvokeNoError() throws {
        let result = try MiniproInvoker.invoke(arguments: ["-k"])
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdErr, "t48: T48\n")
        XCTAssertEqual(result.stdOut, "")
    }

    func testInvokeError() throws {
        let result = try MiniproInvoker.invoke(arguments: ["-p"])
        XCTAssertEqual(result.exitCode, 1)
        XCTAssertTrue(result.stdErr.contains("minipro: option requires an argument -- p"))
        XCTAssertEqual(result.stdOut, "")
    }
}
