//
//  XgproFirmwareUtils.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/1/26.
//

import Foundation
import os

enum XgproFirmwareUtilsError: Error {
    case firmwareNotFound
    case fileTooSmall
    case readFailed
}

struct FirmwareInfo {
    let programmerType: String
    let fileURL: URL
    let firmwareVersion: String
}

class XgproFirmwareUtils {
    private static let t56FileName = "updatet56.dat"
    private static let t76FileName = "updatet76.dat"
    private static let logger = Logger(
        subsystem: "com.3d-logic.visualminipro",
        category: "XgproFirmwareUtils"
    )

    public static func getFirmwareInfo(in folder: URL) throws -> FirmwareInfo {
        let entries = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        var t56Match: URL?
        var t76Match: URL?
        for entry in entries {
            let name = entry.lastPathComponent.lowercased()
            if name == t76FileName {
                t76Match = entry
            } else if name == t56FileName {
                t56Match = entry
            }
        }

        if let t76Match {
            let version = try extractFirmwareVersion(from: t76Match)
            logger.notice("Detected T76 firmware file at \(t76Match.path, privacy: .public)")
            return FirmwareInfo(programmerType: "T76", fileURL: t76Match, firmwareVersion: version)
        }
        if let t56Match {
            let version = try extractFirmwareVersion(from: t56Match)
            logger.notice("Detected T56 firmware file at \(t56Match.path, privacy: .public)")
            return FirmwareInfo(programmerType: "T56", fileURL: t56Match, firmwareVersion: version)
        }
        logger.notice("No firmware file found in \(folder.path, privacy: .public)")
        throw XgproFirmwareUtilsError.firmwareNotFound
    }

    private static func extractFirmwareVersion(from fileURL: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: fileURL)
        defer { try? handle.close() }
        guard let headerData = try handle.read(upToCount: 2) else {
            logger.notice("Failed to read firmware header from \(fileURL.path, privacy: .public)")
            throw XgproFirmwareUtilsError.readFailed
        }
        if headerData.count < 2 {
            logger.notice("Firmware file too small: \(fileURL.path, privacy: .public)")
            throw XgproFirmwareUtilsError.fileTooSmall
        }
        let versionField = try readUInt16(from: headerData)
        logger.notice("Extracted firmware version \(versionField, privacy: .public) from \(fileURL.path, privacy: .public)")
        return String(versionField)
    }

    private static func readUInt16(from data: Data) throws -> UInt16 {
        if data.count < 2 {
            throw XgproFirmwareUtilsError.fileTooSmall
        }
        return try data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                throw XgproFirmwareUtilsError.readFailed
            }
            return baseAddress.load(as: UInt16.self)
        }
    }
}
