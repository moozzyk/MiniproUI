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

    /// Pin count if this chip's package is DIP (e.g. "DIP32" -> 32), otherwise nil.
    var dipPinCount: Int? {
        // minipro reports most non-DIP chips (e.g. W25Q32JV@SOIC8) as DIP, so trust the package in the name if present.
        if let atIndex = name.firstIndex(of: "@"), !name[atIndex...].uppercased().contains("DIP") {
            return nil
        }
        guard let package = deviceInfo.first(where: { $0.key == "Package" })?.value,
              package.uppercased().hasPrefix("DIP") else {
            return nil
        }
        return Int(package.dropFirst(3))
    }
}

class DeviceDetailsProcessor {
    private static let deviceInfoKeys = [
        "Name", "Manufacturer", "Package", "Default VCC voltage", "Vector count", "Memory", "Read buffer size",
        "Write buffer size", "Protocol",
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
