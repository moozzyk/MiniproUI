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
    var skipVerification: Bool = false
    var unprotectBeforeWrite: Bool = false
    var protectAfterWrite: Bool = false
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
        let result = try await MiniproInvoker.invoke(arguments: ["--list"])
        return try SupportedDevicesProcessor.run(result)
    }

    static func getDeviceDetails(device: String) async throws -> DeviceDetails {
        try await ensureProgrammerConnected()
        let result = try await MiniproInvoker.invoke(arguments: ["--get_info", device])
        return try DeviceDetailsProcessor.run(result)
    }

    static func testLogicIC(device: String) async throws -> LogicICTestResult {
        let result = try await MiniproInvoker.invoke(arguments: ["--logic_test", "--device", device])
        return try LogicICTestProcessor.run(result, device: device)
    }

    static func readDeviceId(device: String) async throws -> String {
        let result = try await MiniproInvoker.invoke(arguments: ["--device", device, "--read_id"])
        return try DeviceIdProcessor.run(result)
    }

    static func read(device: String, progressUpdate: @escaping ((ProgressUpdate) -> Void)) async throws -> Data {
        let result = try await MiniproInvoker.invoke(arguments: ["--device", device, "--read", "-"]) { progress in
            if let update = ProgressUpdateProcessor.run(progress) {
                progressUpdate(update)
            }
        }
        return try ReadProcessor.run(result)
    }

    static func write(
        device: String, data: Data, writeOptions: WriteOptions, progressUpdate: @escaping ((ProgressUpdate) -> Void)
    ) async throws {
        var arguments = ["--device", device, "--write", "-"]
        if writeOptions.ignoreFileSizeMismatch {
            arguments.append("--no_size_error")
        }
        if writeOptions.ignoreChipIdMismatch {
            arguments.append("--no_id_error")
        }
        if writeOptions.skipVerification {
            arguments.append("--skip_verify")
        }
        if writeOptions.unprotectBeforeWrite {
            arguments.append("--unprotect")
        }
        if writeOptions.protectAfterWrite {
            arguments.append("--protect")
        }

        let result = try await MiniproInvoker.invoke(arguments: arguments, stdinData: data) { progress in
            if let update = ProgressUpdateProcessor.run(progress) {
                progressUpdate(update)
            }
        }

        try WriteProcessor.run(result, writeOptions)
    }

    static func updateFirmware(firmwareFilePath: String, progressUpdate: @escaping ((ProgressUpdate) -> Void))
        async throws
    {
        let result = try await MiniproInvoker.invoke(
            arguments: ["--update", firmwareFilePath], stdinData: Data("y".utf8)
        ) {
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
