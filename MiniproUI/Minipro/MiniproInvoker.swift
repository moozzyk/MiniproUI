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
    private static let queue = DispatchQueue(label: "MiniproInvokeQueue")

    public static func invoke(arguments: [String], stdinData: Data? = nil) async throws -> InvocationResult {
        return try await withCheckedThrowingContinuation { continuation in
            let logger = Logger(subsystem: "com.3d-logic.visualminipro", category: "MiniproInvoker")
            guard let executablePath = Bundle.main.path(forAuxiliaryExecutable: "minipro")
            else {
                logger.error("minipro executable not found")
                continuation.resume(throwing: InvocationError.executableNotFound)
                return
            }
            queue.async {
                do {
                    logger.notice("invoking minipro with arguments: \(arguments, privacy: .public)")
                    var stdout = Data()
                    var stderr = Data()
                    let stdoutPipe = Pipe()
                    let stderrPipe = Pipe()
                    let stdInPipe = Pipe()
                    stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                        stdout.append(handle.availableData)
                    }
                    stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                        stderr.append(handle.availableData)
                    }

                    let process = Process()
                    process.executableURL = URL(fileURLWithPath: executablePath)
                    process.currentDirectoryURL = Bundle.main.resourceURL
                    process.arguments = arguments
                    process.standardOutput = stdoutPipe
                    process.standardError = stderrPipe
                    process.standardInput = stdInPipe
                    try process.run()
                    if let stdinData = stdinData {
                        try stdInPipe.fileHandleForWriting.write(contentsOf: stdinData)
                        stdInPipe.fileHandleForWriting.closeFile()
                    }
                    process.waitUntilExit()
                    let invocationResult = InvocationResult(
                        exitCode: process.terminationStatus,
                        stdOut: stdout,
                        stdErr: String(data: stderr, encoding: .utf8) ?? ""
                    )
                    logger.notice("invocation completed \(String(describing: invocationResult), privacy: .public)")
                    continuation.resume(returning: invocationResult)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
