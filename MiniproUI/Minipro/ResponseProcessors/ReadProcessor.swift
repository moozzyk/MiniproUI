//
//  ReadProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 4/3/25.
//

import Foundation

class ReadProcessor {
    private static let numErrors = /Logic test failed: (\S+) errors encountered/

    public static func run(_ result: InvocationResult) throws -> Data {
        let stdErr = result.stdErr
        try ensureNoError(invocationResult: result)

        if stdErr.contains("Unsupported device!") {
            throw MiniproAPIError.unsupportedChip
        }

        let invalidChipId = /Invalid Chip ID: expected \S+, got .*[^\n]/
        if let matchedString = stdErr.firstMatch(of: invalidChipId) {
            throw MiniproAPIError.invalidChip(String(matchedString.0))
        }

        if result.exitCode != 0 {
            throw MiniproAPIError.readError("Reading chip failed. Exit code: \(result.exitCode)")
        }

        return result.stdOut
    }
}
