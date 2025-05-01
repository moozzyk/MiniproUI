//
//  MiniproInvoker.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/3/25.
//

import Foundation

struct InvocationResult {
    let exitCode: Int32
    let stdOut: Data
    let stdErr: String

    var stdOutString: String {
        String(data: stdOut, encoding: .utf8) ?? ""
    }
}

enum InvocationError: Error {
    case executableNotFound
}

class MiniproInvoker {
    private static let queue = DispatchQueue(label: "MiniproInvokeQueue")

    public static func invoke(arguments: [String], stdinData: Data? = nil) async throws -> InvocationResult {
        return try await withCheckedThrowingContinuation { continuation in
            guard let executablePath = Bundle.main.path(forAuxiliaryExecutable: "minipro")
            else {
                continuation.resume(throwing: InvocationError.executableNotFound)
                return
            }
            queue.async {
                do {
                    print("starting \(arguments)")
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
                    print("completed \(arguments)")
                    continuation.resume(
                        returning:
                            InvocationResult(
                                exitCode: process.terminationStatus,
                                stdOut: stdout,
                                stdErr: String(data: stderr, encoding: .utf8) ?? ""
                            ))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
