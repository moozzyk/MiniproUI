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

// Write code that extracts Device Code, Serial Code and Manufacting Date from this text:
// Found T48 00.1.31 (0x11f)\nWarning: T48 support is experimental!\nDevice code: 46A16257\nSerial code: HSSCVO9LARFMOYKYOMVE5123\nManufactured: 2024-06-2816:55\nUSB speed: 480Mbps (USB 2.0)\nSupply voltage: 5.11 V\nT48: hardware_check not implemented\n
