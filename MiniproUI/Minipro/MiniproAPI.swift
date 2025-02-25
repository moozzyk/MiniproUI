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
    case deviceNotFound(String)
    case unknownError(String)
}

class MiniproAPI {
    private static func ensureProgrammerConnected() async throws {
        let _ = try await getProgrammerInfo()
    }
    static func getProgrammerInfo() async throws -> ProgrammerInfo {
        let result = try await MiniproInvoker.invoke(arguments: ["-t"])
        return try ProgrammerInfoProcessor.run(result)
    }

    static func getSupportedDevices() async throws -> [String] {
        try await ensureProgrammerConnected()
        let result = try await MiniproInvoker.invoke(arguments: ["-l"])
        return try SupportedDevicesProcessor.run(result)
    }

    static func getDeviceDetails(device: String) async throws -> DeviceDetails {
        try await ensureProgrammerConnected()
        let result = try await MiniproInvoker.invoke(arguments: ["-d", device])
        return try DeviceDetailsProcessor.run(result)
    }

    static func testLogicIC(device: String) async throws -> LogicICTestResult {
        let result = try await MiniproInvoker.invoke(arguments: ["-T", "-p", device])
        return try LogicICTestProcessor.run(result, device: device)
    }
}
