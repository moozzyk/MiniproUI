//
//  VisualMiniproInfoProcessor.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 8/27/25.
//

import Foundation

struct VisualMiniproInfo: Equatable, Hashable {
    let visualMiniproDetails: [KeyValuePair]
    var version: String {
        get {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        }
    }
}

class VisualMiniproInfoProcessor {
    private static let miniproVersion = /minipro version\s+(\S+)/
    private static let miniproCommitKeys = [
        "Commit date", "Git commit", "Git branch",
    ]

    public static func run(_ result: InvocationResult) throws -> VisualMiniproInfo {
        return VisualMiniproInfo(visualMiniproDetails: getVisualMiniproDetails() + getMiniproDetails(result))
    }

    private static func getVisualMiniproDetails() -> [KeyValuePair] {
        let visualMiniproDetails = [
            KeyValuePair(key: "Commit date", value: getCommitDate()),
            KeyValuePair(key: "Git commit", value: getGitCommit()),
            KeyValuePair(key: "Git branch", value: getGitBranch()),
        ]
        return visualMiniproDetails
    }

    private static func getMiniproDetails(_ result: InvocationResult) -> [KeyValuePair] {
        let resultLines = result.stdErr.split(separator: "\n")
        let miniproCommitInfo = extractInfo(resultLines: resultLines, keys: miniproCommitKeys).map{
            KeyValuePair(key: "minipro \($0.key.lowercased())", value: $0.value)
        }

        return extractMiniproVersion(from: result.stdErr) + miniproCommitInfo
    }

    private static func extractMiniproVersion(from stdErr: String) -> [KeyValuePair] {
        let miniProversionMatch = try? miniproVersion.firstMatch(in: stdErr)
        if let miniProversionMatch {
            return [KeyValuePair(key: "minipro version", value: String(miniProversionMatch.1))]
        }
        return []
    }
}
