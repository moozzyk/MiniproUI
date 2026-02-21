//
//  WriteProcessorTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 5/1/25.
//

import Foundation
import Testing

@testable import Visual_Minipro

struct WriteProcessorTests {

    @Test func writeProcessorSuccessfulResponseT48() async throws {
        // command: minipro --device W27C512@DIP28 --write {file}
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                "Found T48 00.1.31 (0x11f)\nWarning: T48 support is experimental!\nDevice code: 46A16257\nSerial code: HSSCVO9LARFMOYKYOMVE5123\nManufactured: 2024-06-2816:55\nUSB speed: 480Mbps (USB 2.0)\nSupply voltage: 5.13 V\nChip ID: 0xDA08  OK\nWarning: Incorrect file size: 1024 (needed 65536)\nErasing... 0.30Sec OK\n\r\u{1b}[KWriting  Code...   0%\r\u{1b}[KWriting  Code...  12%\r\u{1b}[KWriting  Code...  25%\r\u{1b}[KWriting  Code...  37%\r\u{1b}[KWriting  Code...  50%\r\u{1b}[KWriting  Code...  62%\r\u{1b}[KWriting  Code...  75%\r\u{1b}[KWriting  Code...  87%\r\u{1b}[KWriting Code...  0.35Sec  OK\n\r\u{1b}[KReading Code...   0%\r\u{1b}[KReading Code...  0.01Sec  OK\nVerification OK\n"
        )

        #expect(throws: Never.self) {
            try WriteProcessor.run(miniproResult, WriteOptions())
        }
    }

    @Test func writeProcessorSuccessfulResponseT76() async throws {
        // command: minipro --device W27C512@DIP28 --write {file}
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                "Found T76 00.1.13 (0x10d)\nWarning: T76 support is experimental!\nDevice code: 58A02670\nSerial code: 5M55O5G378PD0XBAXPXD3032\nManufactured: 2025-08-1817:22\nUSB speed: 480Mbps (USB 2.0)\nSupply voltage: 5.25 V (USB)\n\nUsing overridden database file /Users...ading Code...  87%\n\r\u{1b}[KReading Code...  89%\n\r\u{1b}[KReading Code...  90%\n\r\u{1b}[KReading Code...  92%\n\r\u{1b}[KReading Code...  93%\n\r\u{1b}[KReading Code...  95%\n\r\u{1b}[KReading Code...  96%\n\r\u{1b}[KReading Code...  98%\n\r\u{1b}[KReading Code...  46.6 ms  OK\nVerification OK\nFPGA Reset  OK\n"
        )

        #expect(throws: Never.self) {
            try WriteProcessor.run(miniproResult, WriteOptions())
        }
    }

    @Test func writeProcessorVerificationFailedT48() async throws {
        // command: minipro --device AM27128A@DIP28 --no_id_error --no_size_error --write {file}
        // condition: non-matching chip, non-matching file size
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                """
                Found T48 00.1.33 (0x121)
                Warning: T48 support is not yet complete!
                Warning: Firmware is out of date.
                Expected  01.1.34 (0x122)
                Found     00.1.33 (0x121)
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.10 V
                WARNING: Chip ID mismatch: expected 0xDA01, got 0xFDFD (unknown)
                Warning: Incorrect file size: 16384 (needed 131072)
                Erasing... 9.01Sec OK
                Writing  Code...   0%
                Verification failed at address 0x0000: File=0xF3, Device=0xFD
                """)
        #expect(
            throws: MiniproAPIError.verificationFailed("Verification failed at address 0x0000: File=0xF3, Device=0xFD")
        ) {
            try WriteProcessor.run(
                miniproResult, WriteOptions(ignoreFileSizeMismatch: true, ignoreChipIdMismatch: true))
        }
    }

    @Test func writeProcessorVerificationFailedT76() async throws {
        // command: minipro --device AM27128A@DIP28 --no_id_error --no_size_error --write {file}
        // condition: non-matching chip, non-matching file size
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                """
                Found T76 00.1.13 (0x10d)
                Warning: T76 support is experimental!
                Device code: 58A02670
                Serial code: 5M55O5G378PD0XBAXPXD3032
                Manufactured: 2025-08-1817:22
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.25 V (USB)

                Using overridden database file /Users...Reading Code...  90%
                \u{1b}[KReading Code...  92%
                \u{1b}[KReading Code...  93%
                \u{1b}[KReading Code...  95%
                \u{1b}[KReading Code...  96%
                \u{1b}[KReading Code...  98%
                \u{1b}[KReading Code...  59.9 ms  OK
                Verification failed at address 0x0001: File=0x01, Device=0x00
                FPGA Reset  OK
                """)
        #expect(
            throws: MiniproAPIError.verificationFailed("Verification failed at address 0x0001: File=0x01, Device=0x00")
        ) {
            try WriteProcessor.run(
                miniproResult, WriteOptions(ignoreFileSizeMismatch: true, ignoreChipIdMismatch: true))
        }
    }

    @Test func writeProcessorIncorrectFileSizeT48() async throws {
        // command: minipro --device AM27128A@DIP28 --no_id_error --write {file}
        // condition: non-matching chip, non-matching file size
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.12 V
                Incorrect file size: 32768 (needed 512, use -s/S to ignore)
                """
        )

        #expect(throws: MiniproAPIError.incorrectFileSize(512, 32768)) {
            try WriteProcessor.run(miniproResult, WriteOptions())
        }
    }

    @Test func writeProcessorIncorrectFileSizeT76() async throws {
        // command: minipro --device AM27128A@DIP28 --no_id_error --write {file}
        // condition: non-matching chip, non-matching file size
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                """
                Found T76 00.1.13 (0x10d)
                Warning: T76 support is experimental!
                Device code: 58A02670
                Serial code: 5M55O5G378PD0XBAXPXD3032
                Manufactured: 2025-08-1817:22
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.25 V (USB)

                Using overridden database file /Users/moozzyk/Library/Containers/com.moozzyk.MiniproUI/Data/Library/Application Support/T76/0x10d/algorithm.xml
                Using T76 ROM28P31 algorithm..
                Chip ID: 0xDA08  OK
                Incorrect file size: 16384 (needed 65536, use -s/S to ignore)
                FPGA Reset  OK
                """
        )

        #expect(throws: MiniproAPIError.incorrectFileSize(65536, 16384)) {
            try WriteProcessor.run(miniproResult, WriteOptions())
        }
    }

    @Test func writeProcessorInvalidChipIdT48() async throws {
        // command: minipro --device AM27128A@DIP28 --write {file}
        // condition: non-matching chip, non-matching file size
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.12 V

                VPP=-V, VDD=2.1V, VCC=-V, Pulse=100us
                Invalid Chip ID: expected 0x97D6, got 0xF8FF (unknown)
                (use '-y' to continue anyway at your own risk)
                """)

        #expect(throws: MiniproAPIError.invalidChip("0x97D6", "0xF8FF")) {
            try WriteProcessor.run(miniproResult, WriteOptions())
        }
    }

    @Test func writeProcessorInvalidChipIdT76() async throws {
        // command: minipro --device AM27128A@DIP28 --write {file}
        // condition: non-matching chip, non-matching file size
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                """
                Found T76 00.1.13 (0x10d)
                Warning: T76 support is experimental!
                Device code: 58A02670
                Serial code: 5M55O5G378PD0XBAXPXD3032
                Manufactured: 2025-08-1817:22
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.25 V (USB)

                Using overridden database file /Users...zyk/Library/Containers/com.moozzyk.MiniproUI/Data/Library/Application Support/T76/0x10d/algorithm.xml
                Using T76 ROM32P11 algorithm..
                Invalid Chip ID: expected 0xDA01, got 0x0000 (unknown)
                (use '-y' to continue anyway at your own risk)
                FPGA Reset  OK
                """)

        #expect(throws: MiniproAPIError.invalidChip("0xDA01", "0x0000")) {
            try WriteProcessor.run(miniproResult, WriteOptions())
        }
    }

    @Test func writeProcessorChipMismatchSizeMismatchIgnoredSkipVerifyT48() async throws {
        // command: minipro --device W27C512@DIP28 --skip_verify --no_size_error --write
        // condition: invalid file size, skip verify
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                """
                Found T48 00.1.33 (0x121)
                Warning: T48 support is not yet complete!
                Warning: Firmware is out of date.
                  Expected  01.1.34 (0x122)
                  Found     00.1.33 (0x121)
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.10 V
                WARNING: Chip ID mismatch: expected 0xDA01, got 0xFDFD (unknown)
                Warning: Incorrect file size: 16384 (needed 131072)
                Erasing... 9.00Sec OK
                Writing Code...  0.29Sec  OK
                """)

        #expect(throws: Never.self) {
            try WriteProcessor.run(
                miniproResult,
                WriteOptions(
                    ignoreFileSizeMismatch: true, ignoreChipIdMismatch: true, skipVerification: true))
        }
    }

    @Test func writeProcessorChipMismatchSizeMismatchIgnoredSkipVerifyT76() async throws {
        // command: minipro --device W27C512@DIP28 --skip_verify --no_size_error --write
        // condition: invalid file size, skip verify
        let miniproResult = InvocationResult(
            exitCode: 0,
            stdOut:
                Data(),
            stdErr:
                """
                Found T76 00.1.13 (0x10d)
                Warning: T76 support is experimental!
                Device code: 58A02670
                Serial code: 5M55O5G378PD0XBAXPXD3032
                Manufactured: 2025-08-1817:22
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.25 V (USB)

                Using overridden database file /Users...gorithm.xml
                Using T76 ROM28P31 algorithm..
                WARNING: Chip ID mismatch: expected 0xDA08, got 0x0000 (unknown)
                Warning: Incorrect file size: 16384 (needed 65536)
                
                \u{1b}[KErasing... 
                \u{1b}[KErasing... 5.23 Sec  OK
                
                \u{1b}[KWriting Code...  
                \u{1b}[KWriting Code...   0%
                \u{1b}[KWriting Code...  87%
                \u{1b}[KWriting Code...  89%
                \u{1b}[KWriting Code...  90%
                \u{1b}[KWriting Code...  92%
                \u{1b}[KWriting Code...  93%
                \u{1b}[KWriting Code...  95%
                \u{1b}[KWriting Code...  96%
                \u{1b}[KWriting Code...  98%
                \u{1b}[KWriting Code...  183.9 ms  OK
                FPGA Reset  OK
                """)

        #expect(throws: Never.self) {
            try WriteProcessor.run(
                miniproResult,
                WriteOptions(
                    ignoreFileSizeMismatch: true, ignoreChipIdMismatch: true, skipVerification: true))
        }
    }


    @Test func writeProcessorOvercurrentProtection() async throws {
        // command: ??
        // When trying to program a Logic Chip (no longer reproduces but still can happen)
        let miniproResult = InvocationResult(
            exitCode: 1,
            stdOut:
                Data(),
            stdErr:
                """
                Found T48 00.1.31 (0x11f)
                Warning: T48 support is experimental!
                Device code: 46A16257
                Serial code: HSSCVO9LARFMOYKYOMVE5123
                Manufactured: 2024-06-2816:55
                USB speed: 480Mbps (USB 2.0)
                Supply voltage: 5.12 V
                WARNING: Chip ID mismatch: expected 0xDA08, got 0xFFFF (unknown)
                Erasing... 0.30Sec OK
                Writing  Code...   0%
                Overcurrent protection!
                """)

        #expect(throws: MiniproAPIError.unknownError("Overcurrent protection! Exit code: 1")) {
            try WriteProcessor.run(miniproResult, WriteOptions())
        }
    }
}
