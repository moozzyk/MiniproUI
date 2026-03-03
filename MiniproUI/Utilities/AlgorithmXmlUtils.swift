//
//  AlgorithmXmlUtils.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/1/26.
//

import Foundation

class AlgorithmXmlUtils {
    public static func resolveAlgorithmXmlPath(programmerInfo: ProgrammerInfo?) throws -> URL {
        guard let programmerInfo,
            let firmwareVersion = programmerInfo.getFirmwareVersionNumber()
        else {
            throw MiniproAPIError.programmerInfoUnavailable
        }
        return try resolveAlgorithmXmlPath(
            programmerModel: programmerInfo.model,
            firmwareVersion: firmwareVersion
        )
    }

    public static func resolveAlgorithmXmlPath(
        programmerModel: ProgrammerModel,
        firmwareVersion: UInt16
    ) throws -> URL {
        let baseDirectory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let versionFolderName = String(format: "0x%x", firmwareVersion)
        return
            baseDirectory
            .appendingPathComponent(programmerModel.rawValue, isDirectory: true)
            .appendingPathComponent(versionFolderName, isDirectory: true)
            .appendingPathComponent("algorithm.xml")
    }

    public static func needsAlgorithmInstallation(programmerInfo: ProgrammerInfo?) -> Bool {
        guard
            let programmerInfo,
            programmerInfo.model.isAlgoBased,
            let firmwareVersion = programmerInfo.getFirmwareVersionNumber(),
            let algorithmXmlPath = try? resolveAlgorithmXmlPath(
                programmerModel: programmerInfo.model,
                firmwareVersion: firmwareVersion
            )
        else {
            return false
        }

        return !FileManager.default.fileExists(atPath: algorithmXmlPath.path)
    }
}
