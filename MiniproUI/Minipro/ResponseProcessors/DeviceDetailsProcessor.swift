//
//  DeviceDetailsProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation

struct KeyValuePair: Equatable {
    let key: String
    let value: String
}

struct DeviceDetails: Equatable {
    let deviceInfo: [KeyValuePair]
    let programmingInfo: [KeyValuePair]
    let isLogicChip: Bool
}

class DeviceDetailsProcessor {
    private static let deviceNotFound = /Device (.*) not found!/
    private static let deviceInfoKeys = [
        "Name", "Available on", "Memory", "Package", "ICSP", "VCC voltage", "Vector count", "Protocol",
        "Read buffer size", "Write buffer size",
    ]
    private static let programmingInfoKeys = [
        "VPP programming voltage", "VDD write voltage", "VCC verify voltage", "Pulse delay",
    ]

    public static func run(_ result: InvocationResult) throws -> DeviceDetails {
        try ensureNoError(invocationResult: result)
        let deviceNotFountMatch = try? deviceNotFound.firstMatch(in: result.stdErr)
        guard deviceNotFountMatch == nil else {
            throw APIError.deviceNotFound(String(deviceNotFountMatch!.1))
        }

        let resultLines = result.stdErr.split(separator: "\n")
        let deviceInfo = extractInfo(resultLines: resultLines, keys: deviceInfoKeys)
        let programmingInfo = extractInfo(resultLines: resultLines, keys: programmingInfoKeys)
        let isLogicChip = deviceInfo.last?.key == "Vector count"
        return DeviceDetails(deviceInfo: deviceInfo, programmingInfo: programmingInfo, isLogicChip: isLogicChip)
    }

    private static func extractInfo(resultLines: [Substring], keys: [String]) -> [KeyValuePair] {
        var info = [KeyValuePair]()
        keys.forEach { key in
            resultLines.forEach { line in
                if line.starts(with: key) {
                    info.append(KeyValuePair(key: key, value: line.dropFirst(key.count + 1).trimmingCharacters(in: .whitespacesAndNewlines)))
                }
            }
        }
        return info
    }
}
