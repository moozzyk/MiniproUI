//
//  ProgrammerInfoView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/2/25.
//

import SwiftUI
import os

struct ProgrammerInfoView: View {
    @Binding var programmerInfo: ProgrammerInfo?
    @State var progressUpdate: ProgressUpdate?
    @State var firmwareFileUrl: URL?
    @State var progressMessage: String?

    private var showProgress: Bool { progressMessage != nil }

    private var isAlgoBasedProgrammer: Bool {
        guard let model = programmerInfo?.model else {
            return false
        }
        return model.isAlgoBased
    }

    private var isFirmwareUpdateSupported: Bool {
        programmerInfo?.model.supportsFirmwareUpdate ?? false
    }

    func getProgrammerName(_ programmerInfo: ProgrammerInfo?) -> String {
        let programmerModel = programmerInfo?.model
        if let model = programmerModel {
            return "Minipro \(model.rawValue)"
        }
        return "Unknown"
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                TabHeaderView(
                    caption: "Programmer: " + getProgrammerName(programmerInfo),
                    secondaryCaption: programmerInfo?.firmwareVersion,
                    systemImageName: "cpu.fill"
                )
                Form {
                    if programmerInfo?.model == nil {
                        ProgrammerNotConnected()
                    } else {
                        Section {
                            PropertyRow(label: "Model ", value: programmerInfo?.model.rawValue ?? "Unknown")
                            PropertyRow(label: "Firmware Version ", value: programmerInfo?.firmwareVersion ?? "Unknown")
                            PropertyRow(label: "Device Code ", value: programmerInfo?.deviceCode ?? "Unknown")
                            PropertyRow(label: "Serial Number ", value: programmerInfo?.serialNumber ?? "Unknown")
                            PropertyRow(
                                label: "Manufactured Date",
                                value: programmerInfo?.dateManufactured ?? "Unknown"
                            )
                            PropertyRow(label: "USB Speed", value: programmerInfo?.usbSpeed ?? "Unknown")
                            PropertyRow(label: "Supply Voltage", value: programmerInfo?.supplyVoltage ?? "Unknown")
                        }
                    }

                    if programmerInfo?.warnings.count ?? 0 > 0 {
                        Section(
                            header: HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                                Text("Warnings")
                            }
                        ) {
                            ForEach(programmerInfo?.warnings ?? [], id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    if isFirmwareUpdateSupported {
                        if isAlgoBasedProgrammer {
                            SoftwareUpdateSection(
                                firmwareUrl: $firmwareFileUrl,
                                programmerInfo: $programmerInfo
                            )
                        } else {
                            FirmwareUpdateSection(firmwareUrl: $firmwareFileUrl, programmerInfo: $programmerInfo)
                        }
                    }
                }
                .formStyle(.grouped)
            }
        }
        .frame(minWidth: 400, minHeight: 500)
        .task {
            programmerInfo = try? await MiniproAPI.getProgrammerInfo()
        }
    }
}

struct FirmwareUpdateSection: View {
    @Binding var firmwareUrl: URL?
    @Binding var programmerInfo: ProgrammerInfo?

    var body: some View {
        Section(
            header: HStack {
                Text("Firmware Update")
            }
        ) {
            HStack {
                Text("Firmware")
                Spacer()
                OpenFileButton(caption: "Select Firmware...", fileTypes: ["dat"]) { url in
                    firmwareUrl = url
                }
            }
            HStack {
                Text("Firmware file: \(firmwareUrl?.lastPathComponent ?? "N/A")")
                    .help(firmwareUrl?.path ?? "")
                Spacer()
                UpdateFirmwareButton(
                    firmwareUrl: $firmwareUrl,
                    programmerInfo: $programmerInfo,
                    buttonCaption: "Update..."
                )
            }.disabled(firmwareUrl == nil)
            Link(
                "Learn more about downloading firmware",
                destination: URL(
                    string: "https://github.com/moozzyk/MiniproUI/wiki/Downloading-Firmware"
                )!
            )
        }
    }
}

struct SoftwareUpdateSection: View {
    private enum MissingAlgorithmsInfo {
        case matchingBundle(String)
        case latestKnownBundle(String)
        case unknownBundle
    }

    @Binding var firmwareUrl: URL?
    @Binding var programmerInfo: ProgrammerInfo?
    @State private var softwareChecksumStatus: SoftwareBundleVerificationStatus?

    private var missingAlgorithmsInfo: MissingAlgorithmsInfo? {
        guard
            AlgorithmXmlUtils.needsAlgorithmInstallation(programmerInfo: programmerInfo),
            let programmerInfo,
            let firmwareVersion = programmerInfo.getFirmwareVersionNumber()
        else {
            return nil
        }

        if let softwareName = XgproFirmwareUtils.getSoftwareName(
            programmerModel: programmerInfo.model,
            firmwareVersion: firmwareVersion
        ) {
            return .matchingBundle(softwareName)
        }

        if let latestSoftwareName = XgproFirmwareUtils.getLatestSoftwareName(programmerModel: programmerInfo.model) {
            return .latestKnownBundle(latestSoftwareName)
        }

        return .unknownBundle
    }

    private func checksumIcon(for status: SoftwareBundleVerificationStatus) -> String {
        switch status {
        case .checksumMatch:
            return "checkmark.circle.fill"
        case .checksumNotAvailable:
            return "exclamationmark.triangle.fill"
        case .checksumMismatch, .programmerModelMismatch, .verificationFailed:
            return "xmark.circle.fill"
        }
    }

    private func checksumColor(for status: SoftwareBundleVerificationStatus) -> Color {
        switch status {
        case .checksumMatch:
            return .green
        case .checksumNotAvailable:
            return .yellow
        case .checksumMismatch, .programmerModelMismatch, .verificationFailed:
            return .red
        }
    }

    private func verificationDetails(for status: SoftwareBundleVerificationStatus) -> String? {
        switch status {
        case .checksumMatch:
            return nil
        case .checksumNotAvailable:
            return "Checksum verification was not possible for this bundle."
        case .checksumMismatch:
            return "Bundle checksum does not match expected value."
        case .programmerModelMismatch:
            return "This bundle targets a different programmer model."
        case .verificationFailed:
            return "Failed to verify bundle checksum."
        }
    }

    private func verificationCaptionColor(for status: SoftwareBundleVerificationStatus) -> Color {
        switch status {
        case .checksumNotAvailable:
            return .orange
        case .checksumMismatch, .programmerModelMismatch, .verificationFailed:
            return .red
        case .checksumMatch:
            return .clear
        }
    }

    var body: some View {
        Section(
            header: HStack {
                Text("Software Bundle Installation")
            }
        ) {
            if let missingAlgorithmsInfo {
                ErrorBanner {
                    VStack(alignment: .leading, spacing: 6) {
                        switch missingAlgorithmsInfo {
                        case .matchingBundle(let softwareName):
                            HStack(spacing: 4) {
                                Text("Missing algorithms for installed firmware. Matching bundle:")
                                Text(softwareName)
                                    .font(.system(.body, design: .monospaced))
                            }
                            Text("Installing any other bundle may update the programmer firmware.")
                        case .latestKnownBundle(let latestSoftwareName):
                            Text(
                                "Missing algorithms for installed firmware. Install software matching your firmware version, or the latest known version: \(latestSoftwareName)."
                            )
                        case .unknownBundle:
                            Text(
                                "Missing algorithms for installed firmware. Install software matching your firmware version."
                            )
                        }
                    }
                }
            }
            HStack {
                Text("Software Bundle")
                Spacer()
                OpenFileButton(caption: "Select Bundle...", fileTypes: ["rar"]) { url in
                    firmwareUrl = url
                    softwareChecksumStatus = XgproFirmwareUtils.verifySoftwareBundle(
                        fileURL: url,
                        programmerModel: programmerInfo?.model
                    )
                }
            }
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Software Bundle file:")
                        if let fileName = firmwareUrl?.lastPathComponent {
                            Text(fileName)
                                .font(.system(.body, design: .monospaced))
                        } else {
                            Text("N/A")
                        }
                    }
                    .help(firmwareUrl?.path ?? "")
                    if let softwareChecksumStatus, let verificationDetails = verificationDetails(for: softwareChecksumStatus) {
                        Text(verificationDetails)
                            .font(.caption)
                            .foregroundColor(verificationCaptionColor(for: softwareChecksumStatus))
                    }
                }
                Spacer()
                if let softwareChecksumStatus {
                    Image(systemName: checksumIcon(for: softwareChecksumStatus))
                        .foregroundColor(checksumColor(for: softwareChecksumStatus))
                        .help(verificationDetails(for: softwareChecksumStatus) ?? "")
                }
                UpdateFirmwareButton(
                    firmwareUrl: $firmwareUrl,
                    programmerInfo: $programmerInfo,
                    buttonCaption: "Install..."
                )
            }.disabled(firmwareUrl == nil)
            Link(
                "Learn more about downloading software",
                destination: URL(
                    string: "https://github.com/moozzyk/MiniproUI/wiki/Downloading-Firmware"
                )!
            )
        }
    }
}

struct UpdateFirmwareButton: View {
    private enum SoftwareBundleValidationError: LocalizedError {
        case programmerNotConnected
        case programmerModelMismatch

        var errorDescription: String? {
            switch self {
            case .programmerNotConnected:
                return "Programmer not connected."
            case .programmerModelMismatch:
                return "Selected software bundle does not match the connected programmer."
            }
        }
    }

    @Binding var firmwareUrl: URL?
    @Binding var programmerInfo: ProgrammerInfo?
    let buttonCaption: String
    @State private var progressUpdate: ProgressUpdate?
    @State private var errorAlertTitle = "Firmware Update Failed"
    @State private var errorMessage: DialogErrorMessage?
    @State private var isPresented = false
    @State private var progressMessage: String?
    private let logger = Logger(subsystem: "com.3d-logic.visualminipro", category: "UpdateFirmwareButton")

    private func installFirmware(using firmwareUrl: URL) async throws {
        progressUpdate = nil
        progressMessage = "Updating firmware..."
        try await MiniproAPI.updateFirmware(firmwareFilePath: firmwareUrl.path()) {
            progressUpdate = $0
        }
        progressUpdate = ProgressUpdate(operation: "", percentage: 100)
        await Task.yield()
        programmerInfo = try await MiniproAPI.getProgrammerInfo()
        try await Task.sleep(nanoseconds: 500 * 1_000_000)
    }

    private func updateFirmware(using firmwareUrl: URL) async {
        do {
            try await installFirmware(using: firmwareUrl)
        } catch {
            errorMessage = .init(message: error.localizedDescription)
        }
    }

    private func createExtractionProgressTask() -> Task<Void, Never> {
        Task {
            let totalSteps = 100
            let maxPercentage = 90
            for step in 1...totalSteps {
                try? await Task.sleep(nanoseconds: 100 * 1_000_000)
                if Task.isCancelled {
                    return
                }
                let percentage = Int((Double(step) / Double(totalSteps)) * Double(maxPercentage))
                await MainActor.run {
                    progressUpdate = ProgressUpdate(operation: "Extracting Files", percentage: percentage)
                }
            }
        }
    }

    private func processRarFirmware(at firmwareUrl: URL) async {
        do {
            let outputDirectory = try await unpackFirmwareArchive(at: firmwareUrl)
            defer {
                do {
                    try FileManager.default.removeItem(at: outputDirectory)
                    logger.notice("Removed extracted firmware directory at \(outputDirectory.path, privacy: .public)")
                } catch {
                    logger.notice(
                        "Failed to remove extracted firmware directory at \(outputDirectory.path, privacy: .public): \(error.localizedDescription, privacy: .public)"
                    )
                }
            }
            let firmwareInfo = try XgproFirmwareUtils.getFirmwareInfo(in: outputDirectory)
            guard let programmerInfo else {
                throw SoftwareBundleValidationError.programmerNotConnected
            }

            guard firmwareInfo.programmerModel == programmerInfo.model else {
                throw SoftwareBundleValidationError.programmerModelMismatch
            }

            progressUpdate = nil
            progressMessage = "Preparing Algorithms..."
            let algorithmsXml = try await XgproFirmwareUtils.createAlgorithmXml(
                in: outputDirectory,
                programmerModel: firmwareInfo.programmerModel
            ) {
                progressUpdate = $0
            }
            let algorithmsUrl = try AlgorithmXmlUtils.resolveAlgorithmXmlPath(
                programmerModel: firmwareInfo.programmerModel,
                firmwareVersion: firmwareInfo.firmwareVersion
            )
            try FileManager.default.createDirectory(
                at: algorithmsUrl.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try algorithmsXml.write(to: algorithmsUrl, atomically: true, encoding: .utf8)
            logger.notice("Saved algorithms XML to \(algorithmsUrl.path, privacy: .public)")

            guard let installedFirmwareVersion = programmerInfo.getFirmwareVersionNumber() else {
                throw MiniproAPIError.programmerInfoUnavailable
            }

            if installedFirmwareVersion != firmwareInfo.firmwareVersion {
                let firmwareFile = outputDirectory.appendingPathComponent(firmwareInfo.fileName)
                try await installFirmware(using: firmwareFile)
            }
        } catch {
            errorMessage = .init(message: error.localizedDescription)
        }
    }

    private func unpackFirmwareArchive(at firmwareUrl: URL) async throws -> URL {
        let extractionProgressTask = createExtractionProgressTask()
        defer {
            extractionProgressTask.cancel()
        }
        let outputDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(
            "xgpro-firmware-\(UUID().uuidString)",
            isDirectory: true
        )
        logger.notice("Extracting firmware archive to \(outputDirectory.path, privacy: .public)")
        try await XgproSoftwareExtractor.extractRar(
            inputURL: firmwareUrl,
            outputDirectory: outputDirectory
        )
        progressUpdate = ProgressUpdate(operation: "Extracting Files", percentage: 100)
        await Task.yield()
        return outputDirectory
    }

    var body: some View {
        Button(buttonCaption) {
            if let firmwareUrl = firmwareUrl {
                isPresented = true
                Task {
                    defer {
                        isPresented = false
                        progressUpdate = nil
                        progressMessage = nil
                    }
                    if firmwareUrl.pathExtension.lowercased() == "rar" {
                        errorAlertTitle = "Software Install Failed"
                        progressMessage = "Extracting firmware..."
                        await processRarFirmware(at: firmwareUrl)
                    } else {
                        errorAlertTitle = "Firmware Update Failed"
                        await updateFirmware(using: firmwareUrl)
                    }
                }
            }
        }
        .disabled(firmwareUrl == nil)
        .sheet(isPresented: $isPresented) {
            ModalDialogView {
                ProgressBarView(label: $progressMessage, progressUpdate: $progressUpdate)
            }
        }
        .alert(item: $errorMessage) {
            Alert(
                title: Text(errorAlertTitle),
                message: Text($0.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    ProgrammerInfoView(
        programmerInfo: .constant(
            ProgrammerInfo(
                model: .t48,
                firmwareVersion: "00.1.31 (0x11f)",
                deviceCode: "46A16257",
                serialNumber: "HSSCVO9LARFMOYKYOMVE5123",
                dateManufactured: "2024-06-28 16:55",
                usbSpeed: "480Mbps (USB 2.0)",
                supplyVoltage: "5.11 V",
                warnings: ["T48 support is experimental"]
            )
        )
    )
}
