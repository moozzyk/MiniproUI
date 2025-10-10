//
//  WriteProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 5/1/25.
//

import Foundation

class WriteProcessor {
    public static func run(_ result: InvocationResult, _ writeOptions: WriteOptions) throws {
        try ensureNoError(invocationResult: result, ignoreInvalidChipId: writeOptions.ignoreChipIdMismatch)

        let stdErr = result.stdErr
        if writeOptions.skipVerification {
            if stdErr.contains(/Writing .* OK/) {
                return
            }
        } else {
            if stdErr.hasSuffix("Verification OK\n") {
                return
            }

            let verificationFailedRegex = /Verification failed at address.*$/
            let verificationFailedMatch = try? verificationFailedRegex.firstMatch(in: stdErr)
            if let verificationFailedMatch = verificationFailedMatch {
                throw MiniproAPIError.verificationFailed(String(verificationFailedMatch.0))
            }
        }

        if !writeOptions.ignoreFileSizeMismatch {
            let incorrectFileSizeRegex = /Incorrect file size: (\d+) \(needed (\d+)/
            let incorrectFileSizeMatch = try? incorrectFileSizeRegex.firstMatch(in: stdErr)
            if let incorrectFileSizeMatch = incorrectFileSizeMatch {
                throw MiniproAPIError.incorrectFileSize(
                    Int32(incorrectFileSizeMatch.2)!, Int32(incorrectFileSizeMatch.1)!)
            }
        }

        throw MiniproAPIError.unknownError(
            "\(stdErr.split(separator: "\n").last ?? "") Exit code: \(result.exitCode)")
    }
}
