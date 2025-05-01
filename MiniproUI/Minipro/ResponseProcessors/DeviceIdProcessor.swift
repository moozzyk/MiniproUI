//
//  DeviceIdProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 4/28/25.
//

import Foundation

class DeviceIdProcessor {
    public static func run(_ result: InvocationResult) throws -> String {
        try ensureNoError(invocationResult: result)

        let chipIdMismatchRegex = /Chip ID mismatch: expected (\S+), got (\S+)/
        let chipIdMismatchMatch = try? chipIdMismatchRegex.firstMatch(in: result.stdErr)
        if let chipIdMismatchMatch = chipIdMismatchMatch {
            throw MiniproAPIError.chipIdMismatch(String(chipIdMismatchMatch.1), String(chipIdMismatchMatch.2))
        }


        let chipIdRegex = /Chip ID: +(\S+) +OK/
        if let chipId = try? chipIdRegex.firstMatch(in: result.stdErr)?.1 {
            return String(chipId)
        }

        throw MiniproAPIError.unknownError("Failed to get device ID")
    }
}
