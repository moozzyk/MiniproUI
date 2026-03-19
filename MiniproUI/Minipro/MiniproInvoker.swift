//
//  MiniproInvoker.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/3/25.
//

import Foundation
import os

struct InvocationResult: CustomDebugStringConvertible {
    let exitCode: Int32
    let stdOut: Data
    let stdErr: String

    var stdOutString: String {
        String(data: stdOut, encoding: .utf8) ?? ""
    }

    var debugDescription: String {
        return
            """
            exitCode: \(exitCode)
            stdOut: \(shorten(stdOutString))
            stdErr: \(shorten(stdErr))
            """
    }

    private func shorten(_ string: String) -> String {
        let maxLength = 500
        if string.count <= maxLength {
            return string
        }
        let prefix = string.prefix(maxLength / 2)
        let suffix = string.suffix(maxLength / 2)
        return "\(prefix)...\(suffix)"
    }
}

enum InvocationError: Error {
    case executableNotFound
}

class MiniproInvoker {
    private static let libusbLogger = Logger(
        subsystem: "com.3d-logic.visualminipro", category: "libusb")

    public static func invoke(
        arguments: [String], stdinData: Data? = nil, onProgress: @escaping ((Data) -> Void) = ({ _ in })
    )
        async throws
        -> InvocationResult
    {
        let logger = Logger(subsystem: "com.3d-logic.visualminipro", category: "MiniproInvoker")
        guard let executablePath = Bundle.main.path(forAuxiliaryExecutable: "minipro") else {
            logger.error("minipro executable not found")
            throw InvocationError.executableNotFound
        }
        let result = try await ProcessInvoker.invoke(
            executableURL: URL(fileURLWithPath: executablePath),
            arguments: arguments,
            stdinData: stdinData,
            currentDirectoryURL: Bundle.main.resourceURL,
            onProgress: onProgress
        )
        return filterLibusbLines(from: result)
    }

    static func filterLibusbLines(from result: InvocationResult) -> InvocationResult {
        let libusbHeader = "[timestamp] [threadID] facility level [function call] <message>"
        let libusbSeparator = String(repeating: "-", count: 80)
        let lines = result.stdErr.components(separatedBy: "\n")
        var normalLines: [String] = []
        for line in lines {
            if line.contains("] libusb: ") {
                libusbLogger.notice("\(line, privacy: .public)")
            } else if line == libusbHeader || line == libusbSeparator {
                // libusb preamble — discard
            } else {
                normalLines.append(line)
            }
        }
        return InvocationResult(
            exitCode: result.exitCode,
            stdOut: result.stdOut,
            stdErr: normalLines.joined(separator: "\n")
        )
    }
}
