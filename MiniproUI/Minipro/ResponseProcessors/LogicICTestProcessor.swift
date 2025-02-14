//
//  LogicICTestProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/13/25.
//

import Foundation

struct LogicICTestResult: Equatable {
    public let device: String
    public let numErrors: Int
    public var isSuccess: Bool { return numErrors == 0 }
    public let testVectors: [[String]]
}

class LogicICTestProcessor {
    private static let numErrors = /Logic test failed: (\S+) errors encountered/

    public static func run(_ result: InvocationResult, device: String) throws -> LogicICTestResult {
        try ensureNoError(invocationResult: result)
        let lines = result.stdOut.split(separator: "\n")
        guard lines.count > 0 else {
            throw APIError.unknownError("Unexpected response format.")
        }

        return LogicICTestResult(
            device: device,
            numErrors: Int((try? numErrors.firstMatch(in: result.stdErr)?.1) ?? "") ?? 0,
            testVectors: lines.dropFirst().map(parseTestVector))
    }

    private static func parseTestVector(line: Substring) -> [String] {
        return line.split(separator: " ")
            .dropFirst()
            .dropLast()
            .map { s in String(s.suffix(1) == "-" ? s.suffix(2) : s.suffix(1)) }
    }
}
