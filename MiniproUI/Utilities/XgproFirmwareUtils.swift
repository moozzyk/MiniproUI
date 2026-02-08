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
        guard let headerData = try handle.read(upToCount: 8) else {
            logger.notice("Failed to read firmware header from \(fileURL.path, privacy: .public)")
            throw XgproFirmwareUtilsError.readFailed
        }
        if headerData.count < 8 {
            logger.notice("Firmware file too small: \(fileURL.path, privacy: .public)")
            throw XgproFirmwareUtilsError.fileTooSmall
        }
        let versionField = try readUInt32LE(from: headerData, offset: 4)
        let maskedVersion = versionField & 0x0000ffff
        logger.notice("Extracted firmware version \(maskedVersion, privacy: .public) from \(fileURL.path, privacy: .public)")
        return String(maskedVersion)
    }

    private static func readUInt32LE(from data: Data, offset: Int) throws -> UInt32 {
        if data.count < offset + 4 {
            throw XgproFirmwareUtilsError.fileTooSmall
        }
        let base = data.startIndex + offset
        return
            UInt32(data[base]) |
            (UInt32(data[base + 1]) << 8) |
            (UInt32(data[base + 2]) << 16) |
            (UInt32(data[base + 3]) << 24)
    }
}
