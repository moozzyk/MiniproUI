//
//  InvocationUtils.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 1/19/25.
//

import Foundation

struct InvocationResult {
    let exitCode: Int32
    let stdOut: String
    let stdErr: String
}

func invokeStatus() -> InvocationResult {
    do {
        let result = try miniproInvoke(["-k"])
        print("\(result)")
        print("Exit code: \(result.exitCode)")
        return result
    } catch let e {
        print("\(e)")
        return InvocationResult(exitCode: -1, stdOut: "", stdErr: "")
    }
}

enum InvocationError: Error {
    case executableNotFound
}

func miniproInvoke(_ args: [String]) throws -> InvocationResult {
    guard let executableUrl = Bundle.main.url(forAuxiliaryExecutable: "minipro")
    else {
        throw InvocationError.executableNotFound
    }

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
    process.executableURL = executableUrl
    process.currentDirectoryURL = Bundle.main.resourceURL
    process.arguments = args
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
