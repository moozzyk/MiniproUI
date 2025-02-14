//
//  ReponseProcessorUtils.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation

func ensureNoError(invocationResult: InvocationResult) throws {
    let stdErr = invocationResult.stdErr

    let prgrammerNotFound = "No programmer found"
    if stdErr.contains(prgrammerNotFound) {
        throw APIError.programmerNotFound
    }

    let deviceNotFound = /Device (.*) not found!/
    let deviceNotFountMatch = try? deviceNotFound.firstMatch(in: stdErr)
    if deviceNotFountMatch != nil {
        throw APIError.deviceNotFound(String(deviceNotFountMatch!.1))
    }

    // TODO: Handle: Out of memory
    // Need to ignore "Logic test failed: 10 errors encountered."
    let error = /[Ee]rror(?!s encountered)/
    if stdErr.contains(error) {
        throw APIError.unknownError(stdErr.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
