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
    case readError(String)
    case unsupportedChip
    case invalidChip(String)
    case unknownError(String)
}
