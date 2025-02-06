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
    static func getProgrammerInfo() throws -> ProgrammerInfo {
        let result = try MiniproInvoker.invoke(arguments: ["-t"])
        return try ProgrammerInfoProcessor.run(result)
    }
}
