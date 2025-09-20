//
//  ProgressUpdatePorcessorTests.swift
//  MiniproUITests
//
//  Created by Pawel Kadluczka on 9/13/25.
//
import Foundation
import Testing

@testable import Visual_Minipro

struct ProgressUpdatePorcessorTests {

    @Test func testNilInput() async throws {
        #expect(ProgressUpdateProcessor.run(nil) == nil)
    }

    @Test func testReadingOperations() async throws {
        #expect(
            ProgressUpdateProcessor.run("\u{1B}[KReading Code...   9%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Reading Code", percentage: 9))

        #expect(
            ProgressUpdateProcessor.run("\u{1B}[KReading Data...   37%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Reading Data", percentage: 37))

        #expect(
            ProgressUpdateProcessor.run("\u{1B}[KReading XYZ...   100%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Reading XYZ", percentage: 100))

        #expect(
            ProgressUpdateProcessor.run(
                "\u{1B}[KReading Code...   1%\r\u{1B}[KReading Code...   3%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Reading Code", percentage: 1))
    }

    @Test func testWritingOperations() async throws {
        #expect(
            ProgressUpdateProcessor.run("\u{1B}[KWriting Code...   9%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Writing Code", percentage: 9))

        #expect(
            ProgressUpdateProcessor.run("\u{1B}[KWriting Data...   37%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Writing Data", percentage: 37))

        #expect(
            ProgressUpdateProcessor.run("\u{1B}[KWriting XYZ...   100%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Writing XYZ", percentage: 100))
        #expect(
            ProgressUpdateProcessor.run(
                "\u{1B}[KWriting Data...   1%\r\u{1B}[KReading Code...   3%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Writing Data", percentage: 1))
    }

    @Test func testReflashingOperation() async throws {
        #expect(
            ProgressUpdateProcessor.run("\u{1B}[Reflashing...  2%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Reflashing", percentage: 2))

        #expect(
            ProgressUpdateProcessor.run("\u{1B}[KReflashing... 22%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Reflashing", percentage: 22))

        #expect(
            ProgressUpdateProcessor.run("\u{1B}[KReflashing... 100%\r".data(using: .utf8))
                == ProgressUpdate(operation: "Reflashing", percentage: 100))

        #expect(
            ProgressUpdateProcessor.run("../t48/t48-1.1.34.dat contains firmware version 00.1.34\n\nDo you want to continue with firmware update? y/n:Switching to bootloader... OK\nErasing... OK\nReflashing... \r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  0%\r\u{1b}[KReflashing...  1%\r\u{1b}[KReflashing...  1%\r\u{1b}[KReflashing...  1%\r\u{1b}[KReflashing...  1%\r\u{1b}[KReflashing...  1%\r\u{1b}[KReflashing...  1%\r\u{1b}[KReflashing...  1%\r\u{1b}[KReflashing...  1%\r\u{1b}[KReflashing...  1%\r\u{1b}[KReflashing...  2%\r\u{1b}[KReflashing...  2%\r\u{1b}[KReflashing...  2%\r\u{1b}[KReflashing...  2%\r\u{1b}[KReflashing...  2%\r\u{1b}[KReflashing...  2%\r\u{1b}[KReflashing...  2%\r\u{1b}[KReflashing...  2%\r\u{1b}[KReflashing...  2%\r\u{1b}[KReflashing...  2%\r\u{1b}[KReflashing...  3%\r\u{1b}[KReflashing...  3%\r\u{1b}[KReflashing...  3%\r\u{1b}[KReflashing...  3%\r\u{1b}[KReflashing...  3%\r\u{1b}[KReflashing...  3%\r\u{1b}[KReflashing...  3%\r\u{1b}[KReflashing...  3%\r\u{1b}[KReflashing...  3%\r\u{1b}[KReflashing... ".data(using: .utf8))
                == ProgressUpdate(operation: "Reflashing", percentage: 0))
        #expect(
            ProgressUpdateProcessor.run("Reflashing... 82%\r\u{1b}[KReflashing... 83%\r\u{1b}[KReflashing... 83%\r\u{1b}[KReflashing... 83%\r\u{1b}[KReflashing... 83%\r\u{1b}[KReflashing... 83%\r\u{1b}[KReflashing... 83%\r\u{1b}[KReflashing... 83%\r\u{1b}[KReflashing... 83%\r\u{1b}[KReflashing... 83%\r\u{1b}[KReflashing... 83%\r\u{1b}[KReflashing... 84%\r\u{1b}[KReflashing... 84%\r\u{1b}[KReflashing... 84%\r\u{1b}[KReflashing... 84%\r\u{1b}[KReflashing... 84%\r\u{1b}[KReflashing... 84%\r\u{1b}[KReflashing... 84%\r\u{1b}[KReflashing... 84%\r\u{1b}[KReflashing... 84%\r\u{1b}[KReflashing... 85%\r\u{1b}[KReflashing... 85%\r\u{1b}[KReflashing... 85%\r\u{1b}[KReflashing... 85%\r\u{1b}[KReflashing... 85%\r\u{1b}[KReflashing... 85%\r\u{1b}[KReflashing... 85%\r\u{1b}[KReflashing... 85%\r\u{1b}[KReflashing... 85%\r\u{1b}[KReflashing... 85%\r\u{1b}[KReflashing... 86%\r\u{1b}[KReflashing... 86%\r\u{1b}[KReflashing... 86%\r\u{1b}[KReflashing... 86%\r\u{1b}[KReflashing... 86%\r\u{1b}[KReflashing... 86%\r\u{1b}[KReflashing... 86%\r\u{1b}[KReflashing... 86%\r\u{1b}[KReflashing... 86%\r\u{1b}[KReflashing... 87%\r\u{1b}[KReflashing... 87%\r\u{1b}[KReflashing... 87%\r\u{1b}[KReflashing... 87%\r\u{1b}[KReflashing... 87%\r\u{1b}[KReflashing... 87%\r\u{1b}[KReflashing... 87%\r\u{1b}[KReflashing... 87%\r\u{1b}[KReflashing... 87%\r\u{1b}[KReflashing... 88".data(using: .utf8))
                == ProgressUpdate(operation: "Reflashing", percentage: 82)
        )

    }

    @Test func testRandomInputs() async throws {
        let inputs = ["", "stdErr: Found T48 00.1.34 (0x122)", "Some Code...   34%"]
        for i in inputs {
            #expect(ProgressUpdateProcessor.run(i.data(using: .utf8)) == nil)
        }
    }
}
