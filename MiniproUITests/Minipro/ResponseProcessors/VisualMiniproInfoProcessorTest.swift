//
//  VisualMiniproInfoProcessorTest.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 8/27/25.
//

import Foundation
import Testing

@testable import Visual_Minipro

struct VisualMiniproInfoProcessorTest {

    @Test func visualMiniproInfoSuccessfulResponse() async throws {
        let miniproResult = InvocationResult(
            exitCode: 0, stdOut: Data(),
            stdErr:
                """
                Supported programmers: TL866A/CS, TL866II+, T48 (experimental)
                Found T48 00.1.33 (0x121)
                Warning: T48 support is experimental!
                Warning: Firmware is newer than expected.
                  Expected  01.1.31 (0x11f)
                  Found     00.1.33 (0x121)
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.13 V
                minipro version 0.7.2     A free and open TL866 series programmer
                Commit date:    2024-12-26 21:31:24 -0800
                Git commit:    b9cee362816931a5679ed20bf4ae7bff4b4c1fbb
                Git branch:    master
                TL866A/CS:    14162 devices, 45 custom
                TL866II+:    29235 devices, 47 custom
                T48:        29200 devices, 0 custom
                T56:        31926 devices, 0 custom
                Logic:          283 devices, 6 custom
                """
        )

        let expected = VisualMiniproInfo(
            visualMiniproDetails: [
                KeyValuePair(key: "Commit date", value: getCommitDate()),
                KeyValuePair(key: "Git commit", value: getGitCommit()),
                KeyValuePair(key: "Git branch", value: getGitBranch()),
                KeyValuePair(key: "minipro version", value: "0.7.2"),
                KeyValuePair(key: "minipro commit date", value: "2024-12-26 21:31:24 -0800"),
                KeyValuePair(key: "minipro git commit", value: "b9cee362816931a5679ed20bf4ae7bff4b4c1fbb"),
                KeyValuePair(key: "minipro git branch", value: "master"),
            ])

        let visualMiniproInfo = try VisualMiniproInfoProcessor.run(miniproResult)
        #expect(visualMiniproInfo.version == Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        #expect(visualMiniproInfo == expected)
    }
}
