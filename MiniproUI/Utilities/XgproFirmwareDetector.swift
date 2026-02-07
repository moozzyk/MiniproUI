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
}
