//
//  ReponseProcessorUtils.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation

func ensureNoError(invocationResult: InvocationResult) throws {
    let error = /[Ee]rror/  // TODO: Handle: Out of memory
    let prgrammerNotFound = "No programmer found"
    let stdErr = invocationResult.stdErr

    if stdErr.contains(prgrammerNotFound) {
        throw APIError.programmerNotFound
    }

    if stdErr.contains(error) {
        throw APIError.unknownError(stdErr.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
