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

    @Test func testRandomInputs() async throws {
        let inputs = ["", "stdErr: Found T48 00.1.34 (0x122)", "Some Code...   34%"]
        for i in inputs {
            #expect(ProgressUpdateProcessor.run(i.data(using: .utf8)) == nil)
        }
    }
}
