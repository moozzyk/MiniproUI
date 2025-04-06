//
//  MiniproAPIError.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 4/6/25.
//

import Foundation

enum MiniproAPIError: Error, Equatable {
    case programmerNotFound
    case programmerInfoUnavailable
    case deviceNotFound(String)
    case readError(Int32)
    case unsupportedChip
    case invalidChip(String)
    case unknownError(String)
}

extension MiniproAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .programmerNotFound:
            return "Programmer not found"
        case .programmerInfoUnavailable:
            return "Programmer info unavailable"
        case .deviceNotFound(let deviceID):
            return "Chip not found: \(deviceID)"
        case .readError(let exitCode):
            return "Unknown read error. Exit code: \(exitCode)"
        case .unsupportedChip:
            return "Unsupported chip"
        case .invalidChip(let message):
            return message
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
}
