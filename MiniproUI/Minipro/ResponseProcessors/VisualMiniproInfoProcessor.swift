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
    private static let miniproVersion = /minipro version\s+(\S+)/
    private static let miniproCommitKeys = [
        "Commit date", "Git commit", "Git branch",
    ]

    public static func run(_ result: InvocationResult) throws -> VisualMiniproInfo {
        return VisualMiniproInfo(
            visualMiniproDetails: getVisualMiniproDetails(), miniproDetails: getMiniproDetails(result))
    }

    private static func getVisualMiniproDetails() -> [KeyValuePair] {
        let visualMiniproDetails = [
            KeyValuePair(key: "Version", value: extractBundleMetadata("CFBundleShortVersionString")),
            KeyValuePair(key: "Commit date", value: getCommitDate()),
            KeyValuePair(key: "Git commit", value: getGitCommit()),
            KeyValuePair(key: "Git branch", value: getGitBranch()),
        ]
        return visualMiniproDetails
    }

    private static func extractBundleMetadata(_ key: String) -> String {
        return Bundle.main.infoDictionary?[key] as? String ?? "Unknown"
    }

    private static func getMiniproDetails(_ result: InvocationResult) -> [KeyValuePair] {
        let resultLines = result.stdErr.split(separator: "\n")
        let miniProversionMatch = try? miniproVersion.firstMatch(in: result.stdErr)

        var miniproCommitInfo: [KeyValuePair] = []
        if let miniProversionMatch {
            miniproCommitInfo.append(
                KeyValuePair(key: "Version", value: String(miniProversionMatch.1)))
        }
        miniproCommitInfo.append(contentsOf: extractInfo(resultLines: resultLines, keys: miniproCommitKeys))
        return miniproCommitInfo
    }

}
