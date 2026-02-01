//
//  ProcessInvoker.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/1/26.
//

import Foundation
import os

class ProcessInvoker {
    private static let queue = DispatchQueue(label: "ProcessInvokerQueue")

    public static func invoke(
        executableURL: URL,
        arguments: [String],
        stdinData: Data? = nil,
        currentDirectoryURL: URL? = nil,
        onProgress: @escaping ((Data) -> Void) = ({ _ in })
    )
        async throws
        -> InvocationResult
    {
        return try await withCheckedThrowingContinuation { continuation in
            let logger = Logger(subsystem: "com.3d-logic.visualminipro", category: "ProcessInvoker")
            let executableName = executableURL.lastPathComponent
            queue.async {
                do {
                    logger.notice("invoking \(executableName, privacy: .public) with arguments: \(arguments, privacy: .public)")
                    var stdout = Data()
                    var stderr = Data()
                    let stdoutPipe = Pipe()
                    let stderrPipe = Pipe()
                    let stdInPipe = Pipe()
                    stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                        stdout.append(handle.availableData)
                    }
                    stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                        let data = handle.availableData
                        stderr.append(data)
                        onProgress(data)
                    }

                    let process = Process()
                    process.executableURL = executableURL
                    process.currentDirectoryURL = currentDirectoryURL
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
