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
    case invalidChip(String, String)
    case unknownError(String)
    case ioError(String)
    case chipIdMismatch(String, String)
    case firmwareUpdateError(String)
    case incorrectFileSize(Int32, Int32)
    case verificationFailed(String)
    case logicICTestError(String)
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
        case .invalidChip(let expected, let actual):
            return "Invalid Chip ID: expected \(expected), actual \(actual)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        case .ioError(let message):
            return "IO error: \(message)"
        case .chipIdMismatch(let expected, let actual):
            return "Chip ID mismatch: expected \(expected), actual \(actual)"
        case .incorrectFileSize(let expected, let actual):
            return "Incorrect file size: expected \(expected), actual \(actual)"
        case .firmwareUpdateError(let message):
            return "Firmware update error: \(message)"
        case .verificationFailed(let message):
            return message
        case .logicICTestError(let message):
            return message
        }
    }
}
