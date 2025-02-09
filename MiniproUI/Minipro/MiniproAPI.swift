//
//  MiniproAPI.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/3/25.
//

import Foundation

enum APIError: Error, Equatable {
    case programmerNotFound
    case programmerInfoUnavailable
    case unknownError(String)
}

class MiniproAPI {
    static func getProgrammerInfo() async throws -> ProgrammerInfo {
        let result = try await MiniproInvoker.invoke(arguments: ["-t"])
        return try ProgrammerInfoProcessor.run(result)
    }

    static func getSupportedDevices() async throws -> [String] {
        let result = try await MiniproInvoker.invoke(arguments: ["-l"])
        var seen: Set<String> = []
        return result.stdOut
            .components(separatedBy: .newlines)
            .filter { seen.insert($0).inserted }
    }
}
