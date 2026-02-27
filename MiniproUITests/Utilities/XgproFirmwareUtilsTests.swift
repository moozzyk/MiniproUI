//
//  XgproFirmwareUtilsTests.swift
//  MiniproUITests
//

import Testing
import Foundation

@testable import Visual_Minipro

struct XgproFirmwareUtilsTests {
    @Test func getSoftwareNameReturnsExpectedValueForKnownFirmware() {
        #expect(
            XgproFirmwareUtils.getSoftwareName(programmerModel: "T76", firmwareVersion: 0x10f)
                == "xgpro_T76_V1311.rar")
        #expect(
            XgproFirmwareUtils.getSoftwareName(programmerModel: "t56", firmwareVersion: 0x149)
                == "xgproV1310_T48_T56_T866II_Setup.rar")
        #expect(
            XgproFirmwareUtils.getSoftwareName(programmerModel: "T76", firmwareVersion: 0x9999)
                == nil)
    }

    @Test func createAlgorithmXmlReportsProgressForAlgFiles() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let algorithmDirectory = tempDirectory.appendingPathComponent("algoT76", isDirectory: true)
        try FileManager.default.createDirectory(at: algorithmDirectory, withIntermediateDirectories: true)
        try makeTestAlgFile(name: "T7_first.alg", in: algorithmDirectory)
        try makeTestAlgFile(name: "T7_second.alg", in: algorithmDirectory)

        var updates: [ProgressUpdate] = []
        _ = try await XgproFirmwareUtils.createAlgorithmXml(
            in: tempDirectory,
            programmerModel: "T76"
        ) {
            updates.append($0)
        }

        #expect(updates.count == 3)
        #expect(updates.map(\.percentage) == [0, 50, 100])
        #expect(updates.allSatisfy { $0.operation == "Preparing Algorithms" })
    }

    @Test func createAlgorithmXmlReportsCompletionWhenNoAlgFiles() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let algorithmDirectory = tempDirectory.appendingPathComponent("algoT76", isDirectory: true)
        try FileManager.default.createDirectory(at: algorithmDirectory, withIntermediateDirectories: true)

        var updates: [ProgressUpdate] = []
        _ = try await XgproFirmwareUtils.createAlgorithmXml(
            in: tempDirectory,
            programmerModel: "T76"
        ) {
            updates.append($0)
        }

        #expect(updates.count == 1)
        #expect(updates.first == ProgressUpdate(operation: "Preparing Algorithms", percentage: 100))
    }

    private func makeTestAlgFile(name: String, in directory: URL) throws {
        var data = Data(repeating: 0, count: 5000)
        data[4] = 0x41
        data[5] = 0x42
        data[6] = 0x43
        data[7] = 0x44
        try data.write(to: directory.appendingPathComponent(name))
    }
}
