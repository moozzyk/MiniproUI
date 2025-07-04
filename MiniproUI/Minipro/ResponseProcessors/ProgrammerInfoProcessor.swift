//
//  ProgrammerInfoProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/4/25.
//

import Foundation

struct ProgrammerInfo {
    let model: String
    let firmwareVersion: String
    let deviceCode: String
    let serialNumber: String
    let dateManufactured: String
    let usbSpeed: String
    let supplyVoltage: String
    let warnings: [String]
}

class ProgrammerInfoProcessor {
    private static let model = /Found (\S+)/
    private static let firmwareVersion = /Found \S+ (.+)\n/
    private static let deviceCode = /Device code: (\S+)/
    private static let serialNumber = /Serial code: (\S+)/
    private static let dateManufactured = /Manufactured: (\d{4}-\d{2}-\d{2})(\d{2}:\d{2})/
    private static let usbSpeed = /USB speed: (.+)\n/
    private static let supplyVoltage = /Supply voltage: (.+)\n/

    private static func findWarnings(stdErr: String) -> [String] {
        var warnings: [String] = []
        let lines = stdErr.split(separator: "\n")
        for (index, line) in lines.enumerated() {
            if let range = line.range(of: "Warning: ") {
                let warning = line[range.upperBound...]
                if warning.starts(with: "Firmware is") {
                    warnings.append("\(warning)\(sanitizeVersionWarningLine(line: String(lines[index + 1]))),\(sanitizeVersionWarningLine(line: String(lines[index + 2])))"
                    )
                } else {
                    warnings.append(String(warning))
                }
            }
        }
        return warnings
    }

    private static func sanitizeVersionWarningLine(line: String) -> String {
        return line.replacingOccurrences(of: "[\\s]+", with: " ", options: .regularExpression, range: nil)
    }

    public static func run(_ result: InvocationResult) throws -> ProgrammerInfo {
        try ensureNoError(invocationResult: result)

        let model = try? model.firstMatch(in: result.stdErr)?.1
        let firmwareVersion = try? firmwareVersion.firstMatch(in: result.stdErr)?.1
        let deviceCode = try? deviceCode.firstMatch(in: result.stdErr)?.1
        let serialNumber = try? serialNumber.firstMatch(in: result.stdErr)?.1
        let dateManufacturedMatches = try? dateManufactured.firstMatch(in: result.stdErr)
        let dateManufactured = dateManufacturedMatches.map { "\($0.1) \($0.2)" }
        let usbSpeed = try? usbSpeed.firstMatch(in: result.stdErr)?.1
        let supplyVoltage = try? supplyVoltage.firstMatch(in: result.stdErr)?.1

        guard model != nil && firmwareVersion != nil && deviceCode != nil && serialNumber != nil else {
            throw MiniproAPIError.programmerInfoUnavailable
        }

        return ProgrammerInfo(
            model: String(model!),
            firmwareVersion: String(firmwareVersion!),
            deviceCode: String(deviceCode!),
            serialNumber: String(serialNumber!),
            dateManufactured: String(dateManufactured ?? "N/A"),
            usbSpeed: String(usbSpeed ?? "N/A"),
            supplyVoltage: String(supplyVoltage ?? "N/A"),
            warnings: findWarnings(stdErr: result.stdErr))
    }
}
