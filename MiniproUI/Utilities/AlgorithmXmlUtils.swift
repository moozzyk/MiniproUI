//
//  AlgorithmXmlUtils.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/1/26.
//

import Foundation

class AlgorithmXmlUtils {
    public static func resolveAlgorithmXmlPath(
        programmerType: String,
        firmwareVersion: UInt16
    ) throws -> URL {
        let baseDirectory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let versionFolderName = String(format: "0x%x", firmwareVersion)
        return baseDirectory
            .appendingPathComponent(programmerType.uppercased(), isDirectory: true)
            .appendingPathComponent(versionFolderName, isDirectory: true)
            .appendingPathComponent("algorithm.xml")
    }
}
