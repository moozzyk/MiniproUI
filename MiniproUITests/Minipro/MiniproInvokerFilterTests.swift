//
//  MiniproInvokerFilterTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 3/18/26.
//

import Foundation
import Testing

@testable import Visual_Minipro

struct MiniproInvokerFilterTests {
    @Test func filterRemovesLibusbLines() {
        let stdErr = """
            Supported programmers: TL866A/CS, TL866II+, T48, T56, T76
            [timestamp] [threadID] facility level [function call] <message>
            --------------------------------------------------------------------------------
            [ 0.000007] [001aa780] libusb: debug [libusb_init_context] created default context
            [ 0.000012] [001aa780] libusb: debug [libusb_init_context] libusb v1.0.29.11953
            [ 0.000025] [001aa780] libusb: debug [usbi_add_event_source] add fd 3 events 1
            [ 0.000105] [001aa781] libusb: debug [darwin_event_thread_main] creating hotplug event source
            [ 0.003729] [001aa781] libusb: debug [darwin_event_thread_main] darwin event thread exiting
            [ 0.004086] [001aa780] libusb: debug [usbi_remove_event_source] remove fd 3
            No programmer found.
            minipro version 0.7.4     A free and open TL866 series programmer
            Commit date:    2026-03-08 13:59:37 -0700
            Git commit:    c3ad71e4c6fc66b4e4aef2058b9f91187bac4231
            Git branch:    universal_binary
            Share dir:    /usr/local/share/minipro
            TL866A/CS:    14162 devices, 45 custom
            TL866II+:    29774 devices, 47 custom
            T48:        29739 devices, 0 custom
            T56:        32513 devices, 0 custom
            T76:        32519 devices, 0 custom
            Logic:          283 devices, 6 custom
            """
        let expectedStdErr = """
            Supported programmers: TL866A/CS, TL866II+, T48, T56, T76
            No programmer found.
            minipro version 0.7.4     A free and open TL866 series programmer
            Commit date:    2026-03-08 13:59:37 -0700
            Git commit:    c3ad71e4c6fc66b4e4aef2058b9f91187bac4231
            Git branch:    universal_binary
            Share dir:    /usr/local/share/minipro
            TL866A/CS:    14162 devices, 45 custom
            TL866II+:    29774 devices, 47 custom
            T48:        29739 devices, 0 custom
            T56:        32513 devices, 0 custom
            T76:        32519 devices, 0 custom
            Logic:          283 devices, 6 custom
            """
        let input = InvocationResult(exitCode: 1, stdOut: Data(), stdErr: stdErr)
        let result = MiniproInvoker.filterLibusbLines(from: input)
        #expect(result.exitCode == 1)
        #expect(result.stdOut == Data())
        #expect(result.stdErr == expectedStdErr)
    }

    @Test func filterPassesThroughOutputWithoutLibusbLines() {
        let stdErr = """
            Supported programmers: TL866A/CS, TL866II+, T48, T56, T76
            No programmer found.
            minipro version 0.7.4     A free and open TL866 series programmer
            """
        let input = InvocationResult(exitCode: 0, stdOut: Data(), stdErr: stdErr)
        let result = MiniproInvoker.filterLibusbLines(from: input)
        #expect(result.stdErr == stdErr)
    }
}
