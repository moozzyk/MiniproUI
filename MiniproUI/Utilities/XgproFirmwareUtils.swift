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
    case unsupportedProgrammerType
    case compressionFailed
}

struct FirmwareInfo {
    let programmerType: String
    let fileURL: URL
    let firmwareVersion: UInt16
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

    private static func extractFirmwareVersion(from fileURL: URL) throws -> UInt16 {
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
        logger.notice(
            "Extracted firmware version \(versionField, privacy: .public) from \(fileURL.path, privacy: .public)"
        )
        return versionField
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

    public static func createAlgorithmXml(in baseFolder: URL, programmerType: String) async throws -> String {
        let algorithmFolder = try resolveAlgorithmDirectory(baseFolder: baseFolder, programmerType: programmerType)
        let entries = try FileManager.default.contentsOfDirectory(
            at: algorithmFolder,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        var algorithmElements: [String] = []
        for entry in entries where entry.pathExtension.lowercased() == "alg" {
            logger.notice(
                "Firmware folder entry for \(programmerType, privacy: .public): \(entry.lastPathComponent, privacy: .public)"
            )
            if programmerType == "T76" {
                let element = try await buildAlgorithmElementT76(path: entry)
                algorithmElements.append(element)
            }
        }
        let xml = buildAlgorithmsXml(programmerType: programmerType, algorithmElements: algorithmElements)
        logger.notice("Built algorithms XML with \(algorithmElements.count, privacy: .public) entries")
        return xml
    }

    private static func buildAlgorithmsXml(programmerType: String, algorithmElements: [String]) -> String {
        return """
            <root>
            <database type="ALGORITHMS">
            <algorithms_\(programmerType)>
            \(algorithmElements.joined(separator: "\n"))
            </algorithms_\(programmerType)>
            </database>
            </root>
            """
    }

    private static func resolveAlgorithmDirectory(baseFolder: URL, programmerType: String) throws -> URL {
        switch programmerType {
        case "T76":
            return baseFolder.appendingPathComponent("algoT76", isDirectory: true)
        case "T56":
            return baseFolder.appendingPathComponent("algorithm", isDirectory: true)
        default:
            logger.notice("Unsupported programmer type: \(programmerType, privacy: .public)")
            throw XgproFirmwareUtilsError.unsupportedProgrammerType
        }
    }

    private static func buildAlgorithmElementT76(path: URL) async throws -> String {
        logger.notice("Processing T76 algorithm file at \(path.path, privacy: .public)")
        let algorithmFile = try Data(contentsOf: path)
        let requiredSize = 16 + 4080
        if algorithmFile.count < requiredSize {
            logger.notice("T76 algorithm file too small: \(path.path, privacy: .public)")
            throw XgproFirmwareUtilsError.fileTooSmall
        }
        let algorithmDescription = algorithmFile.subdata(in: 16..<requiredSize)
        let strings = extractStrings(from: algorithmDescription, minimumLength: 4)
        let description = strings.joined(separator: " ")
        logger.notice("T76 algorithm description: \(description, privacy: .public)")
        let bitstream = try await createAlgorithmBitstreamT76(algorithmFile)
        let algorithmName = "28F32P78"
        return
            "<algorithm name=\"\(algorithmName)\" description=\"\(description)\" bitstream=\"\(bitstream)\" />"
    }

    public static func createAlgorithmBitstreamT76(_ data: Data) async throws -> String {
        let algorithmOffset = 4096
        let headerOffset = 4
        let headerLength = 8
        let requiredSize = max(headerOffset + headerLength, algorithmOffset)
        if data.count < requiredSize {
            logger.notice("Algorithm data too small for bitstream: \(data.count, privacy: .public) bytes")
            throw XgproFirmwareUtilsError.fileTooSmall
        }

        let payload = prepareBitstreamPayload(
            data,
            headerOffset: headerOffset,
            headerLength: headerLength,
            algorithmOffset: algorithmOffset
        )
        let gzipData = try await gzipData(payload)
        return gzipData.base64EncodedString()
    }

    private static func prepareBitstreamPayload(
        _ data: Data,
        headerOffset: Int,
        headerLength: Int,
        algorithmOffset: Int
    ) -> Data {
        var payload = Data()
        payload.reserveCapacity(headerLength + max(0, data.count - algorithmOffset))
        payload.append(data.subdata(in: headerOffset..<(headerOffset + headerLength)))
        payload.append(data.subdata(in: algorithmOffset..<data.count))
        return payload
    }

    private static func gzipData(_ data: Data) async throws -> Data {
        let gzipURL = URL(fileURLWithPath: "/usr/bin/gzip")
        let result = try await ProcessInvoker.invoke(
            executableURL: gzipURL,
            arguments: ["-c"],
            stdinData: data
        )
        if result.exitCode != 0 {
            logger.notice("gzip failed with exit code \(result.exitCode, privacy: .public)")
            throw XgproFirmwareUtilsError.compressionFailed
        }
        return result.stdOut
    }

    private static func extractStrings(from data: Data, minimumLength: Int) -> [String] {
        var results: [String] = []
        var current: [UInt8] = []
        current.reserveCapacity(64)

        for byte in data {
            if byte >= 0x20 && byte <= 0x7e {
                current.append(byte)
            } else if current.count >= minimumLength {
                if let string = String(bytes: current, encoding: .ascii) {
                    results.append(string)
                }
                current.removeAll(keepingCapacity: true)
            } else {
                current.removeAll(keepingCapacity: true)
            }
        }
        if current.count >= minimumLength, let string = String(bytes: current, encoding: .ascii) {
            results.append(string)
        }
        return results
    }
}
