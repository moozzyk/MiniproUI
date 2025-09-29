//
//  MiniproAPI.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/3/25.
//

import Foundation

struct WriteOptions {
    var ignoreFileSizeMismatch: Bool = false
    var ignoreChipIdMismatch: Bool = false
}

class MiniproAPI {
    private static func ensureProgrammerConnected() async throws {
        let _ = try await getProgrammerInfo()
    }
    static func getProgrammerInfo() async throws -> ProgrammerInfo {
        let result = try await MiniproInvoker.invoke(arguments: ["--version"])
        return try ProgrammerInfoProcessor.run(result)
    }

    static func getSupportedDevices() async throws -> SupportedDevices {
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

    static func readDeviceId(device: String) async throws -> String {
        let result = try await MiniproInvoker.invoke(arguments: ["-p", device, "-D"])
        return try DeviceIdProcessor.run(result)
    }

    static func read(device: String, progressUpdate: @escaping ((ProgressUpdate) -> Void)) async throws -> Data {
        let result = try await MiniproInvoker.invoke(arguments: ["-p", device, "-r", "-"]) { progress in
            if let update = ProgressUpdateProcessor.run(progress) {
                progressUpdate(update)
            }
        }
        return try ReadProcessor.run(result)
    }

    static func write(
        device: String, data: Data, options: WriteOptions, progressUpdate: @escaping ((ProgressUpdate) -> Void)
    ) async throws {
        var arguments = ["-p", device, "-w", "-"]
        if options.ignoreFileSizeMismatch {
            arguments.append("-s")
        }
        if options.ignoreChipIdMismatch {
            arguments.append("-y")
        }

        let result = try await MiniproInvoker.invoke(arguments: arguments, stdinData: data) { progress in
            if let update = ProgressUpdateProcessor.run(progress) {
                progressUpdate(update)
            }
        }

        try WriteProcessor.run(result)
    }

    static func updateFirmware(firmwareFilePath: String, progressUpdate: @escaping ((ProgressUpdate) -> Void))
        async throws
    {
        let result = try await MiniproInvoker.invoke(arguments: ["-F", firmwareFilePath], stdinData: Data("y".utf8)) {
            progress in
            if let update = ProgressUpdateProcessor.run(progress) {
                progressUpdate(update)
            }
        }
        try UpdateFirmwareProcessor.run(result)
    }

    static func getVisualMiniproInfo() async throws -> VisualMiniproInfo {
        let result = try await MiniproInvoker.invoke(arguments: ["--version"])
        return try VisualMiniproInfoProcessor.run(result)
    }
}
