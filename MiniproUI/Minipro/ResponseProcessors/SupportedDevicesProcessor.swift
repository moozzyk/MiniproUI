//
//  SupportedDevicesProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation

class SupportedDevicesProcessor {
    public static func run(_ result: InvocationResult) throws -> [String] {
        try ensureNoError(invocationResult: result)
        var seen: Set<String> = []
        return result.stdOutString
            .components(separatedBy: .newlines)
            .filter { seen.insert($0).inserted }
    }
}
