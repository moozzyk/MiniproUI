//
//  DeviceDetailsProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation

struct DeviceDetails: Equatable, Hashable {
    let name: String
    let deviceInfo: [KeyValuePair]
    let programmingInfo: [KeyValuePair]
    let isLogicChip: Bool
}

class DeviceDetailsProcessor {
    private static let deviceInfoKeys = [
        "Name", "Available on", "Memory", "Package", "Default VCC voltage", "Vector count", "Protocol",
        "Read buffer size", "Write buffer size",
    ]
    private static let programmingInfoKeys = [
        "Default VPP programming voltage", "Default VDD write voltage", "Default VCC verify voltage",
        "Default write pulse",
    ]

    public static func run(_ result: InvocationResult) throws -> DeviceDetails {
        try ensureNoError(invocationResult: result)

        let resultLines = result.stdErr.split(separator: "\n")
        let name = extractInfo(resultLines: resultLines, keys: ["Name"]).first?.value ?? "(None)"
        let deviceInfo = extractInfo(resultLines: resultLines, keys: deviceInfoKeys)
        let programmingInfo = extractInfo(resultLines: resultLines, keys: programmingInfoKeys)
        let isLogicChip = deviceInfo.last?.key == "Vector count"
        return DeviceDetails(
            name: name, deviceInfo: deviceInfo, programmingInfo: programmingInfo, isLogicChip: isLogicChip)
    }
}
