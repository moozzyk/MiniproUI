//
//  ReadProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 4/3/25.
//

import Foundation

class ReadProcessor {
    public static func run(_ result: InvocationResult) throws -> Data {
        try ensureNoError(invocationResult: result)

        if result.exitCode != 0 {
            throw MiniproAPIError.readError(result.exitCode)
        }

        return result.stdOut
    }
}
