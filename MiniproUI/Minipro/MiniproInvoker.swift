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
        return try await ProcessInvoker.invoke(
            executableURL: URL(fileURLWithPath: executablePath),
            arguments: arguments,
            stdinData: stdinData,
            currentDirectoryURL: Bundle.main.resourceURL,
            onProgress: onProgress
        )
    }
}
