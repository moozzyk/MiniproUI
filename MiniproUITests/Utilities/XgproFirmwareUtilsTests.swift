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
            XgproFirmwareUtils.getSoftwareName(programmerModel: .t76, firmwareVersion: 0x10f)
                == "xgpro_T76_V1311.rar")
        #expect(
            XgproFirmwareUtils.getSoftwareName(programmerModel: .t56, firmwareVersion: 0x149)
                == "xgproV1316_T48_T56_T866II_Setup.rar")
        #expect(
            XgproFirmwareUtils.getSoftwareName(programmerModel: .t76, firmwareVersion: 0x9999)
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
            programmerModel: .t76
        ) {
            updates.append($0)
        }

        #expect(updates.count == 2)
        #expect(updates.map(\.percentage) == [50, 100])
        #expect(updates.allSatisfy { $0.operation == "Preparing Algorithms" })
    }

    @Test func createAlgorithmXmlThrowsWhenNoAlgFiles() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let algorithmDirectory = tempDirectory.appendingPathComponent("algoT76", isDirectory: true)
        try FileManager.default.createDirectory(at: algorithmDirectory, withIntermediateDirectories: true)

        do {
            _ = try await XgproFirmwareUtils.createAlgorithmXml(
                in: tempDirectory,
                programmerModel: .t76
            ) { _ in
            }
            #expect(Bool(false), "Expected createAlgorithmXml to throw")
        } catch let error as XgproFirmwareUtilsError {
            switch error {
            case .algorithmsNotFound:
                #expect(Bool(true))
            default:
                #expect(Bool(false), "Unexpected XgproFirmwareUtilsError: \(String(describing: error))")
            }
        } catch {
            #expect(Bool(false), "Unexpected error type: \(String(describing: error))")
        }
    }

    @Test func createAlgorithmXmlReportsProgressForAlgFilesT56() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let algorithmDirectory = tempDirectory.appendingPathComponent("algorithm", isDirectory: true)
        try FileManager.default.createDirectory(at: algorithmDirectory, withIntermediateDirectories: true)
        try makeTestAlgFileT56(name: "ROM40P82.alg", in: algorithmDirectory, description: "27C400")
        try makeTestAlgFileT56(name: "SPI25F11.alg", in: algorithmDirectory, description: "SPI25F11")

        var updates: [ProgressUpdate] = []
        let xml = try await XgproFirmwareUtils.createAlgorithmXml(
            in: tempDirectory,
            programmerModel: .t56
        ) {
            updates.append($0)
        }

        #expect(updates.count == 2)
        #expect(updates.map(\.percentage) == [50, 100])
        #expect(updates.allSatisfy { $0.operation == "Preparing Algorithms" })
        #expect(xml.contains("ROM40P82"))
        #expect(xml.contains("SPI25F11"))
        #expect(xml.contains("algorithms_T56"))
    }

    @Test func createAlgorithmXmlT56ContainsDescription() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let algorithmDirectory = tempDirectory.appendingPathComponent("algorithm", isDirectory: true)
        try FileManager.default.createDirectory(at: algorithmDirectory, withIntermediateDirectories: true)
        try makeTestAlgFileT56(name: "ROM40P82.alg", in: algorithmDirectory, description: "27C400")

        let xml = try await XgproFirmwareUtils.createAlgorithmXml(
            in: tempDirectory,
            programmerModel: .t56
        )

        #expect(xml.contains("27C400"))
    }

    private func makeTestAlgFile(name: String, in directory: URL) throws {
        var data = Data(repeating: 0, count: 5000)
        data[4] = 0x41
        data[5] = 0x42
        data[6] = 0x43
        data[7] = 0x44
        try data.write(to: directory.appendingPathComponent(name))
    }

    private func makeTestAlgFileT56(name: String, in directory: URL, description: String) throws {
        var data = Data(repeating: 0, count: 0x220 + 100)
        let descBytes = Array(description.utf8)
        data.replaceSubrange(0..<descBytes.count, with: descBytes)
        try data.write(to: directory.appendingPathComponent(name))
    }
}
