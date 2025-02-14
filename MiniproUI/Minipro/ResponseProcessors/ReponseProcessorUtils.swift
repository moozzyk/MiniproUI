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

    let error = /[Ee]rror/  // TODO: Handle: Out of memory
    if stdErr.contains(error) {
        throw APIError.unknownError(stdErr.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    let deviceNotFound = /Device (.*) not found!/
    let deviceNotFountMatch = try? deviceNotFound.firstMatch(in: stdErr)
    if deviceNotFountMatch != nil {
        throw APIError.deviceNotFound(String(deviceNotFountMatch!.1))
    }
}
