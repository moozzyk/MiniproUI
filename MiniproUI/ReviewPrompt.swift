//
//  ReviewPrompt.swift
//  Visual Minipro
//

import Foundation

enum ReviewPrompt {
    private static let minSuccessfulOperations = 5
    #if DEBUG
        private static let minTimeBetweenRequests: TimeInterval = 10 * 60
    #else
        private static let minTimeBetweenRequests: TimeInterval = 60 * 24 * 60 * 60
    #endif

    static func startIfNeeded() {
        if UserDefaults.standard.reviewPeriodStart == nil {
            UserDefaults.standard.reviewPeriodStart = .now
        }
    }

    static func recordSuccessfulOperation() {
        UserDefaults.standard.successfulOperationCount += 1
    }

    static var isReviewDue: Bool {
        let defaults = UserDefaults.standard
        guard defaults.successfulOperationCount >= minSuccessfulOperations,
            let start = defaults.reviewPeriodStart
        else { return false }
        return Date.now >= start.addingTimeInterval(minTimeBetweenRequests)
    }

    static func markReviewRequested() {
        UserDefaults.standard.successfulOperationCount = 0
        UserDefaults.standard.reviewPeriodStart = .now
    }
}
