//
//  XgproFirmwareDetector.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/1/26.
//

import Foundation
import os

enum XgproFirmwareDetectorError: Error {
    case firmwareNotFound
    case fileTooSmall
    case readFailed
}

class XgproFirmwareDetector {
    private static let t56FileName = "updatet56.dat"
    private static let t76FileName = "updatet76.dat"
    private static let logger = Logger(
        subsystem: "com.3d-logic.visualminipro",
        category: "XgproFirmwareDetector"
    )

    enum FirmwareTarget {
        case t56(file: URL)
        case t76(file: URL)
    }

    public static func detectFirmwareTarget(in folder: URL) throws -> FirmwareTarget {
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
            logger.notice("Detected T76 firmware file at \(t76Match.path, privacy: .public)")
            return .t76(file: t76Match)
        }
        if let t56Match {
            logger.notice("Detected T56 firmware file at \(t56Match.path, privacy: .public)")
            return .t56(file: t56Match)
        }
        logger.notice("No firmware file found in \(folder.path, privacy: .public)")
        throw XgproFirmwareDetectorError.firmwareNotFound
    }

    public static func extractFirmwareVersion(from fileURL: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: fileURL)
        defer { try? handle.close() }
        guard let headerData = try handle.read(upToCount: 8) else {
            logger.notice("Failed to read firmware header from \(fileURL.path, privacy: .public)")
            throw XgproFirmwareDetectorError.readFailed
        }
        if headerData.count < 8 {
            logger.notice("Firmware file too small: \(fileURL.path, privacy: .public)")
            throw XgproFirmwareDetectorError.fileTooSmall
        }
        let versionField = try readUInt32LE(from: headerData, offset: 4)
        let maskedVersion = versionField & 0x0000ffff
        logger.notice("Extracted firmware version \(maskedVersion, privacy: .public) from \(fileURL.path, privacy: .public)")
        return String(maskedVersion)
    }

    private static func readUInt32LE(from data: Data, offset: Int) throws -> UInt32 {
        if data.count < offset + 4 {
            throw XgproFirmwareDetectorError.fileTooSmall
        }
        let base = data.startIndex + offset
        return
            UInt32(data[base]) |
            (UInt32(data[base + 1]) << 8) |
            (UInt32(data[base + 2]) << 16) |
            (UInt32(data[base + 3]) << 24)
    }
}
