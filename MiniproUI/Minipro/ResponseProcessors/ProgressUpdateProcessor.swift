//
//  ProgressUpdateProcessor.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 9/13/25.
//

import Foundation

struct ProgressUpdate: Equatable {
    let operation: String
    let percentage: Int
}

class ProgressUpdateProcessor {
    private static let progressRegex = /(Reading\s+\w+|Writing\s+\w+|Reflashing)...\s+(\d+)%/

    public static func run(_ data: Data?) -> ProgressUpdate? {
        guard let data else {
            return nil
        }

        let update = String(data: data, encoding: .utf8)
        if let matchedString = update?.firstMatch(of: progressRegex) {
            return ProgressUpdate(operation: String(matchedString.1), percentage: Int(String(matchedString.2)) ?? 0)
        }
        return nil
    }
}
