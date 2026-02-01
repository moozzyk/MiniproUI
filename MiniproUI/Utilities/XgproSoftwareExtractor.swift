//
//  XgproSoftwareExtractor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/1/26.
//

import Foundation

enum XgproSoftwareExtractorError: Error {
    case toolUnavailable
    case extractionFailed(String)
}

class XgproSoftwareExtractor {
    private static let bsdtarURL = URL(fileURLWithPath: "/usr/bin/bsdtar")

    public static func extractRar(inputURL: URL, outputDirectory: URL) async throws {
        if !FileManager.default.isExecutableFile(atPath: bsdtarURL.path) {
            throw XgproSoftwareExtractorError.toolUnavailable
        }

        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        let firstPass = try await ProcessInvoker.invoke(
            executableURL: bsdtarURL,
            arguments: ["-x", "--to-stdout", "-f", inputURL.path]
        )
        if firstPass.exitCode != 0 {
            throw XgproSoftwareExtractorError.extractionFailed(firstPass.stdErr)
        }

        let secondPass = try await ProcessInvoker.invoke(
            executableURL: bsdtarURL,
            arguments: ["-x", "-f", "-"],
            stdinData: firstPass.stdOut,
            currentDirectoryURL: outputDirectory
        )
        if secondPass.exitCode != 0 {
            throw XgproSoftwareExtractorError.extractionFailed(secondPass.stdErr)
        }
    }
}
