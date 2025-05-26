//
//  UpdateFirmwareResponseProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 5/18/25.
//

import Foundation

class UpdateFirmwareProcessor {

    private static let firmwareUpdateErrors = [
        "open error",
        "file size error",
        "file read error",
        "file version error",
        "file CRC error",
        "failed",
        "Failed"
    ]

    public static func run(_ result: InvocationResult) throws {
        if result.exitCode == 0 && result.stdErr.contains("Reflash... OK") {
            return
        }

        for line in result.stdErr.split(separator: "\n") {
            for error in firmwareUpdateErrors {
                if line.contains(error) {
                    throw MiniproAPIError.firmwareUpdateError(String(line))
                }
            }
        }
        try ensureNoError(invocationResult: result)
        throw MiniproAPIError.unknownError("Failed to update firmware")
    }
}
