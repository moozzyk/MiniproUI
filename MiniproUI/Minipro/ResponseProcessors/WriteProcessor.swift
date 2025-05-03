//
//  WriteProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 5/1/25.
//

import Foundation

class WriteProcessor {
    public static func run(_ result: InvocationResult) throws {
        try ensureNoError(invocationResult: result)

        let stdErr = result.stdErr
        if stdErr.hasSuffix("Verification OK\n") {
            return
        }

        let incorrectFileSizeRegex = /Incorrect file size: (\d+) \(needed (\d+)/
        let incorrectFileSizeMatch = try? incorrectFileSizeRegex.firstMatch(in: stdErr)
        if let incorrectFileSizeMatch = incorrectFileSizeMatch {
            throw MiniproAPIError.incorrectFileSize(Int32(incorrectFileSizeMatch.2)!, Int32(incorrectFileSizeMatch.1)!)

        }

        if result.exitCode != 0 {
            throw MiniproAPIError.readError(result.exitCode)
        }

        throw MiniproAPIError.unknownError("Unknown error")
    }
}

