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
                    let stdoutPipe = Pipe()
                    let stderrPipe = Pipe()
                    let stdInPipe = Pipe()
                    _ = fcntl(stdInPipe.fileHandleForWriting.fileDescriptor, F_SETNOSIGPIPE, 1)

                    let process = Process()
                    process.executableURL = executableURL
                    process.currentDirectoryURL = currentDirectoryURL
                    process.arguments = arguments
                    process.standardOutput = stdoutPipe
                    process.standardError = stderrPipe
                    process.standardInput = stdInPipe
                    try process.run()

                    let group = DispatchGroup()

                    logger.debug("stdout group enter")
                    group.enter()
                    var stdout = Data()
                    stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                        let data = handle.availableData
                        if data.isEmpty {
                            handle.readabilityHandler = nil
                            logger.debug("stdout group leave")
                            group.leave()
                        } else {
                            stdout.append(data)
                        }
                    }

                    logger.debug("stderr group enter")
                    group.enter()
                    var stderr = Data()
                    stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                        let data = handle.availableData
                        if data.isEmpty {
                            handle.readabilityHandler = nil
                            logger.debug("stderr group leave")
                            group.leave()
                        } else {
                            stderr.append(data)
                            onProgress(data)
                        }
                    }

                    if let stdinData = stdinData {
                        let stdinHandle = stdInPipe.fileHandleForWriting
                        do {
                            try stdinHandle.write(contentsOf: stdinData)
                        } catch {
                            logger.notice("stdin write failed: \(error, privacy: .public)")
                        }
                        try? stdinHandle.close()
                    }

                    process.waitUntilExit()
                    logger.debug("process exited")
                    group.notify(queue: queue) {
                        logger.debug("group resume")
                        let invocationResult = InvocationResult(
                            exitCode: process.terminationStatus,
                            stdOut: stdout,
                            stdErr: String(data: stderr, encoding: .utf8) ?? ""
                        )
                        logger.notice("invocation completed \(String(describing: invocationResult), privacy: .public)")
                        continuation.resume(returning: invocationResult)
                    }
                } catch {
                    logger.error("Exception: \(error, privacy: .public)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
