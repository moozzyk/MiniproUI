//
//  MiniproInvoker.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/3/25.
//

import Foundation

struct InvocationResult {
    let exitCode: Int32
    let stdOut: String
    let stdErr: String
}

enum InvocationError: Error {
    case executableNotFound
}

class MiniproInvoker {
    private static let queue = DispatchQueue(label: "MiniproInvokeQueue")

    public static func invoke(arguments: [String]) throws -> InvocationResult {
        guard let executablePath = Bundle.main.path(forAuxiliaryExecutable: "minipro")
        else {
            throw InvocationError.executableNotFound
        }
        return try queue.sync {
            var stdout = Data()
            var stderr = Data()
            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                stdout.append(handle.availableData)
            }
            stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                stderr.append(handle.availableData)
            }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: executablePath)
            process.arguments = arguments
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe
            try process.run()
            process.waitUntilExit()
            return InvocationResult(
                exitCode: process.terminationStatus,
                stdOut: String(data: stdout, encoding: .utf8) ?? "",
                stdErr: String(data: stderr, encoding: .utf8) ?? ""
            )
        }
    }
}
