//
//  DeviceDetailsProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation

class DeviceDetailsProcessor {
    private static let deviceNotFound = /Device (.*) not found!/
    private static let keys = [
        "Name", "Available on", "Memory", "Package", "ICSP", "VCC voltage", "Vector count", "Protocol",
        "Read buffer size", "Write buffer size",
    ]

    public static func run(_ result: InvocationResult) throws -> [(String, String)] {
        try ensureNoError(invocationResult: result)
        let deviceNotFountMatch = try? deviceNotFound.firstMatch(in: result.stdErr)
        guard deviceNotFountMatch == nil else {
            throw APIError.deviceNotFound(String(deviceNotFountMatch!.1))
        }

        var deviceDetails = [(String, String)]()
        let resultLines = result.stdErr.split(separator: "\n")
        keys.forEach { key in
            resultLines.forEach { line in
                if line.starts(with: key) {
                    deviceDetails.append(
                        (
                            key,
                            line.dropFirst(key.count + 1).trimmingCharacters(in: .whitespacesAndNewlines)
                        ))
                }
            }
        }

        return deviceDetails
    }
}
