//
//  VisualMiniproInfoProcessor.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 8/27/25.
//

import Foundation

struct VisualMiniproInfo: Equatable, Hashable {
    let visualMiniproDetails: [KeyValuePair]
    let miniproDetails: [KeyValuePair]
}

class VisualMiniproInfoProcessor {
    private static let miniproVersion = /(minipro version) (\S+)/
    private static let miniproCommitKeys = [
        "Commit date", "Git commit", "Git branch",
    ]

    public static func run(_ result: InvocationResult) throws -> VisualMiniproInfo {
        let resultLines = result.stdErr.split(separator: "\n")

        let miniProversionMatch = try? miniproVersion.firstMatch(in: result.stdErr)

        var miniproCommitInfo: [KeyValuePair] = []
        if let miniProversionMatch {
            miniproCommitInfo.append(KeyValuePair(key: String(miniProversionMatch.1), value: String(miniProversionMatch.2)))
        }
        miniproCommitInfo.append(contentsOf: extractInfo(resultLines: resultLines, keys: miniproCommitKeys))
        return VisualMiniproInfo(visualMiniproDetails: [], miniproDetails: miniproCommitInfo)
    }
}
