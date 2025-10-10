//
//  ReponseProcessorUtils.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation

struct KeyValuePair: Equatable, Hashable {
    let key: String
    let value: String
}

func ensureNoError(invocationResult: InvocationResult, ignoreInvalidChipId: Bool = false) throws {
    let stdErr = invocationResult.stdErr

    if stdErr.contains("No programmer found") {
        throw MiniproAPIError.programmerNotFound
    }

    let deviceNotFound = /Device (.*) not found!/
    let deviceNotFountMatch = try? deviceNotFound.firstMatch(in: stdErr)
    if deviceNotFountMatch != nil {
        throw MiniproAPIError.deviceNotFound(String(deviceNotFountMatch!.1))
    }

    let ioError = /IO error:(.*)/
    let ioErrors = invocationResult.stdErr.split(separator: "\n")
        .map { try? ioError.firstMatch(in: String($0))?.1 }
        .filter { $0 != nil }
        .map { String($0!).trimmingCharacters(in: .whitespacesAndNewlines) }

    if !ioErrors.isEmpty {
        throw MiniproAPIError.ioError(ioErrors.joined(separator: "\n"))
    }

    // TODO: Handle: Out of memory
    // Need to ignore "Logic test failed: 10 errors encountered."
    let error = /[Ee]rror(?!s encountered)/
    if stdErr.contains(error) {
        throw MiniproAPIError.unknownError(stdErr.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    if stdErr.contains("Unsupported device!") || stdErr.contains("NAND chips not supported yet.") {
        throw MiniproAPIError.unsupportedChip
    }

    if !ignoreInvalidChipId {
        let invalidChipId = /Invalid Chip ID: expected (\S+), got (\S+)/
        if let matchedString = stdErr.firstMatch(of: invalidChipId) {
            throw MiniproAPIError.invalidChip(String(matchedString.1), String(matchedString.2))
        }
    }
}

func extractInfo(resultLines: [Substring], keys: [String]) -> [KeyValuePair] {
    var info = [KeyValuePair]()
    keys.forEach { key in
        resultLines.forEach { line in
            if line.starts(with: key) {
                info.append(
                    KeyValuePair(
                        key: key,
                        value: line.dropFirst(key.count + 1).trimmingCharacters(in: .whitespacesAndNewlines)))
            }
        }
    }
    return info
}
