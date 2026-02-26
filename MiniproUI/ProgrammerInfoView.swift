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
        return ["T56", "T76"].contains(model.uppercased())
    }

    private var isFirmwareUpdateSupported: Bool {
        let model = programmerInfo?.model ?? ""
        // firmware update not supported for TL866A and TL866CS
        // due to an additional prompt in the firmware update handler
        return model == "T48" || model == "T56" || model == "TL866II+" || model == "T76"
    }

    func getProgrammerName(_ programmerInfo: ProgrammerInfo?) -> String {
        let programmerModel = programmerInfo?.model
        if let model = programmerModel {
            return "Minipro \(model)"
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
                            PropertyRow(label: "Model ", value: programmerInfo?.model ?? "Unknown")
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
    @Binding var firmwareUrl: URL?
    @Binding var programmerInfo: ProgrammerInfo?
    @State private var softwareChecksumStatus: SoftwareBundleVerificationStatus?

    private var missingAlgorithmsMessage: String? {
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
            return "Missing algorithms for installed firmware. Matching bundle: \(softwareName).\nInstalling any other bundle will update the programmer firmware."
        }

        if let latestSoftwareName = XgproFirmwareUtils.getLatestSoftwareName(programmerModel: programmerInfo.model) {
            return "Missing algorithms for installed firmware. Install software matching your firmware version, or the latest known version: \(latestSoftwareName)."
        }

        return "Missing algorithms for installed firmware. Install software matching your firmware version."
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

    var body: some View {
        Section(
            header: HStack {
                Text("Software Bundle Installation")
            }
        ) {
            if let missingAlgorithmsMessage {
                ErrorBanner {
                    Text(missingAlgorithmsMessage)
                }
            }
            HStack {
                Text("Software Bundle")
                Spacer()
                OpenFileButton(caption: "Select Bundle...", fileTypes: ["rar"]) { url in
                    firmwareUrl = url
                    softwareChecksumStatus = XgproFirmwareUtils.verifySoftwareBundle(
                        fileURL: url,
                        programmerModel: programmerInfo?.model ?? ""
                    )
                }
            }
            HStack {
                Text("Software Bundle file: \(firmwareUrl?.lastPathComponent ?? "N/A")")
                    .help(firmwareUrl?.path ?? "")
                Spacer()
                if let softwareChecksumStatus {
                    Image(systemName: checksumIcon(for: softwareChecksumStatus))
                        .foregroundColor(checksumColor(for: softwareChecksumStatus))
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
    @Binding var firmwareUrl: URL?
    @Binding var programmerInfo: ProgrammerInfo?
    let buttonCaption: String
    @State private var progressUpdate: ProgressUpdate?
    @State private var errorMessage: DialogErrorMessage?
    @State private var isPresented = false
    @State private var progressMessage: String?
    private let logger = Logger(subsystem: "com.3d-logic.visualminipro", category: "UpdateFirmwareButton")

    private func updateFirmware(using firmwareUrl: URL) async {
        do {
            try await MiniproAPI.updateFirmware(firmwareFilePath: firmwareUrl.path()) {
                progressUpdate = $0
            }
            progressUpdate = ProgressUpdate(operation: "", percentage: 100)
            await Task.yield()
            programmerInfo = try await MiniproAPI.getProgrammerInfo()
            try await Task.sleep(nanoseconds: 500 * 1_000_000)
        } catch {
            errorMessage = .init(message: error.localizedDescription)
        }
        isPresented = false
        progressUpdate = nil
        progressMessage = nil
    }

    private func processRarFirmware(at firmwareUrl: URL) async {
        progressMessage = "Extracting firmware..."
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
            let algorithmsXml = try await XgproFirmwareUtils.createAlgorithmXml(
                in: outputDirectory,
                programmerModel: firmwareInfo.programmerModel
            )
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
        } catch {
            errorMessage = .init(message: error.localizedDescription)
        }
        isPresented = false
        progressMessage = nil
    }

    private func unpackFirmwareArchive(at firmwareUrl: URL) async throws -> URL {
        let outputDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(
            "xgpro-firmware-\(UUID().uuidString)",
            isDirectory: true
        )
        logger.notice("Extracting firmware archive to \(outputDirectory.path, privacy: .public)")
        try await XgproSoftwareExtractor.extractRar(
            inputURL: firmwareUrl,
            outputDirectory: outputDirectory
        )
        return outputDirectory
    }

    var body: some View {
        Button(buttonCaption) {
            if let firmwareUrl = firmwareUrl {
                isPresented = true
                Task {
                    if firmwareUrl.pathExtension.lowercased() == "rar" {
                        await processRarFirmware(at: firmwareUrl)
                    } else {
                        progressMessage = "Updating firmware..."
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
                title: Text("Firmware Update Failure"),
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
                model: "T48",
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
