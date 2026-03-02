//
//  XgproFirmwareUtils.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/1/26.
//

import CryptoKit
import Foundation
import os

enum XgproFirmwareUtilsError: Error {
    case firmwareNotFound
    case algorithmsNotFound
    case fileTooSmall
    case readFailed
    case unsupportedProgrammerType
    case compressionFailed
    case unknownSoftwareFile(String)
}

struct FirmwareInfo {
    let programmerModel: String
    let firmwareVersion: UInt16
    let fileName: String
}

private struct SoftwareBundleInfo {
    let firmwareInfo: FirmwareInfo
    let checksum: String
}

public enum SoftwareBundleVerificationStatus {
    case checksumMatch
    case checksumMismatch
    case programmerModelMismatch
    case checksumNotAvailable
    case verificationFailed
}

class XgproFirmwareUtils {
    private static let t56FileName = "updatet56.dat"
    private static let t76FileName = "UpdateT76.Dat"
    private static let logger = Logger(
        subsystem: "com.3d-logic.visualminipro",
        category: "XgproFirmwareUtils"
    )

    private static let softwareInfo: [String: SoftwareBundleInfo] = [
        "xgpro_T76_V1303A.rar": SoftwareBundleInfo(
            firmwareInfo: FirmwareInfo(
                programmerModel: "T76",
                firmwareVersion: 0x10d,
                fileName: t76FileName
            ),
            checksum: "493024ac8951f733e34b42cac66d873ef77f9e12e3547c6f1e5e295d0061f1aa"
        ),
        "xgpro_T76_V1309.rar": SoftwareBundleInfo(
            firmwareInfo: FirmwareInfo(
                programmerModel: "T76",
                firmwareVersion: 0x10e,
                fileName: t76FileName
            ),
            checksum: "72164362cc986742b101eab1a93e884b93f280f9fc0e2e8b6077fd0ca2ab9745"
        ),
        "xgpro_T76_V1311.rar": SoftwareBundleInfo(
            firmwareInfo: FirmwareInfo(
                programmerModel: "T76",
                firmwareVersion: 0x10f,
                fileName: t76FileName
            ),
            checksum: "aad3cc7678676da2e1b2bb0505d7c58e0c74ca1612f805a994eebe6c11473ea8"
        ),
        "xgproV1304_T48_T56_T866II_Setup.rar": SoftwareBundleInfo(
            firmwareInfo: FirmwareInfo(
                programmerModel: "T56",
                firmwareVersion: 0x149,
                fileName: t56FileName
            ),
            checksum: "821db3ef1cc2b335d8a1e50ad37161032f804c8626cd3c1e7d03695d9aa75b1d"
        ),
        "xgproV1306_T48_T56_T866_Setup.rar": SoftwareBundleInfo(
            firmwareInfo: FirmwareInfo(
                programmerModel: "T56",
                firmwareVersion: 0x149,
                fileName: t56FileName
            ),
            checksum: "2110b1af7b8f0274032cef006c7be23d2c28d375e3392040dc9de09f5d35eba6"
        ),
        "xgproV1310_T48_T56_T866II_Setup.rar": SoftwareBundleInfo(
            firmwareInfo: FirmwareInfo(
                programmerModel: "T56",
                firmwareVersion: 0x149,
                fileName: t56FileName
            ),
            checksum: "f3fb94d483c20e0e28d8a53ffd5e0930ef285cfeea008f23691ed097c8dcd0c9"
        ),
    ]

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
            return FirmwareInfo(
                programmerModel: "T76",
                firmwareVersion: version,
                fileName: t76Match.lastPathComponent
            )
        }
        if let t56Match {
            let version = try extractFirmwareVersion(from: t56Match)
            logger.notice("Detected T56 firmware file at \(t56Match.path, privacy: .public)")
            return FirmwareInfo(
                programmerModel: "T56",
                firmwareVersion: version,
                fileName: t56Match.lastPathComponent
            )
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

    public static func createAlgorithmXml(
        in baseFolder: URL,
        programmerModel: String,
        progressUpdate: ((ProgressUpdate) -> Void)? = nil
    ) async throws -> String {
        let algorithmFolder = try resolveAlgorithmDirectory(baseFolder: baseFolder, programmerModel: programmerModel)
        let entries = try FileManager.default.contentsOfDirectory(
            at: algorithmFolder,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        let algorithmEntries = entries.filter { $0.pathExtension.lowercased() == "alg" }
        if algorithmEntries.isEmpty {
            throw XgproFirmwareUtilsError.algorithmsNotFound
        }
        var algorithmElements: [String] = []

        for (index, entry) in algorithmEntries.enumerated() {
            logger.notice(
                "Firmware folder entry for \(programmerModel, privacy: .public): \(entry.lastPathComponent, privacy: .public)"
            )
            if programmerModel == "T76" {
                let element = try await buildAlgorithmElementT76(path: entry)
                algorithmElements.append(element)
            }
            let percentage = Int((Double(index + 1) / Double(algorithmEntries.count)) * 100.0)
            progressUpdate?(ProgressUpdate(operation: "Preparing Algorithms", percentage: percentage))
        }
        let xml = buildAlgorithmsXml(programmerModel: programmerModel, algorithmElements: algorithmElements)
        logger.notice("Built algorithms XML with \(algorithmElements.count, privacy: .public) entries")
        return xml
    }

    private static func buildAlgorithmsXml(programmerModel: String, algorithmElements: [String]) -> String {
        return """
            <root>
            <database type="ALGORITHMS">
            <algorithms_\(programmerModel)>
            \(algorithmElements.joined(separator: "\n"))
            </algorithms_\(programmerModel)>
            </database>
            </root>
            """
    }

    private static func resolveAlgorithmDirectory(baseFolder: URL, programmerModel: String) throws -> URL {
        switch programmerModel {
        case "T76":
            return baseFolder.appendingPathComponent("algoT76", isDirectory: true)
        case "T56":
            return baseFolder.appendingPathComponent("algorithm", isDirectory: true)
        default:
            logger.notice("Unsupported programmer model: \(programmerModel, privacy: .public)")
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
        let algorithmName = algorithmNameT76(for: path)
        let algorithmDescriptionText = algorithmDescriptionT76(from: algorithmFile, fileURL: path)
        let bitstream = try await createAlgorithmBitstreamT76(algorithmFile)
        return """
            <algorithm name="\(algorithmName)"
            description="\(algorithmDescriptionText)"
            bitstream="\(bitstream)" />
            """
    }

    private static func algorithmNameT76(for path: URL) -> String {
        let fileName = path.deletingPathExtension().lastPathComponent
        return fileName.replacingOccurrences(of: "T7_", with: "")
    }

    private static func algorithmDescriptionT76(from algorithmFile: Data, fileURL: URL) -> String {
        let requiredSize = 16 + 4080
        let algorithmDescription = algorithmFile.subdata(in: 16..<requiredSize)
        let strings = extractStrings(from: algorithmDescription, minimumLength: 4)
        let description = strings.joined(separator: " ")
        logger.notice("T76 algorithm description: \(description, privacy: .public)")
        return description
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

    private static func verifySoftwareSHA(fileURL: URL, expectedChecksum: String) throws -> Bool {
        let fileData = try Data(contentsOf: fileURL)
        let digest = SHA256.hash(data: fileData)
        let actualChecksum = digest.map { String(format: "%02x", $0) }.joined()
        return actualChecksum == expectedChecksum
    }

    private static func softwareInfoFor(fileURL: URL) -> SoftwareBundleInfo? {
        let fileName = fileURL.lastPathComponent.lowercased()
        return softwareInfo.first(where: { $0.key.lowercased() == fileName })?.value
    }

    public static func verifySoftwareBundle(
        fileURL: URL,
        programmerModel: String
    ) -> SoftwareBundleVerificationStatus {
        guard let softwareInfo = softwareInfoFor(fileURL: fileURL) else {
            return .checksumNotAvailable
        }

        guard softwareInfo.firmwareInfo.programmerModel == programmerModel.uppercased() else {
            return .programmerModelMismatch
        }

        do {
            return try verifySoftwareSHA(fileURL: fileURL, expectedChecksum: softwareInfo.checksum)
                ? .checksumMatch : .checksumMismatch
        } catch {
            return .verificationFailed
        }
    }

    public static func getSoftwareName(programmerModel: String, firmwareVersion: UInt16) -> String? {
        let normalizedProgrammerModel = programmerModel.uppercased()
        let matches = softwareInfo.compactMap { entry -> String? in
            let (softwareName, softwareInfo) = entry
            guard
                softwareInfo.firmwareInfo.programmerModel == normalizedProgrammerModel,
                softwareInfo.firmwareInfo.firmwareVersion == firmwareVersion
            else {
                return nil
            }
            return softwareName
        }
        return matches.sorted().last
    }

    public static func getLatestSoftwareName(programmerModel: String) -> String? {
        let normalizedProgrammerModel = programmerModel.uppercased()
        let matches = softwareInfo.compactMap { entry -> String? in
            let (softwareName, softwareInfo) = entry
            guard softwareInfo.firmwareInfo.programmerModel == normalizedProgrammerModel else {
                return nil
            }
            return softwareName
        }
        return matches.sorted().last
    }
}
