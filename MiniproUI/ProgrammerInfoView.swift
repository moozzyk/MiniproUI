//
//  ProgrammerInfoView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/2/25.
//

import SwiftUI

struct ProgrammerInfoView: View {
    @Binding var programmerInfo: ProgrammerInfo?
    @State var progressUpdate: ProgressUpdate?
    @State var firmwareFileUrl: URL?
    @State var progressMessage: String?

    private var showProgress: Bool { progressMessage != nil }
    private var isFirmwareUpdateSupported: Bool {
        let model = programmerInfo?.model ?? ""
        // firmware update not supported for TL866A and TL866CS
        // due to an additional prompt in the firmware update handler
        return model == "T48" || model == "T56" || model == "TL866II+"
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
                    systemImageName: "cpu.fill")
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
                                label: "Manufactured Date", value: programmerInfo?.dateManufactured ?? "Unknown")
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
                        Section(
                            header: HStack {
                                Text("Firmware Update")
                            }
                        ) {
                            HStack {
                                Text("Firmware ")
                                Spacer()
                                OpenFileButton(caption: "Select Firmware...") { url in
                                    firmwareFileUrl = url
                                }
                            }
                            HStack {
                                Text("Firmware file: \(firmwareFileUrl?.path ?? "N/A")")
                                Spacer()
                                UpdateFirmwareButton(firmwareUrl: $firmwareFileUrl, programmerInfo: $programmerInfo)
                            }.disabled(firmwareFileUrl == nil)
                            Link(
                                "Learn more about downloading firmware",
                                destination: URL(
                                    string: "https://github.com/moozzyk/MiniproUI/wiki/Downloading-Firmware")!)
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

struct UpdateFirmwareButton: View {
    @Binding var firmwareUrl: URL?
    @Binding var programmerInfo: ProgrammerInfo?
    @State private var progressUpdate: ProgressUpdate?
    @State private var errorMessage: DialogErrorMessage?
    @State private var isPresented = false

    var body: some View {
        Button("Update...") {
            if let firmwareUrl = firmwareUrl {
                isPresented = true
                Task {
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
                }
            }
        }
        .disabled(firmwareUrl == nil)
        .sheet(isPresented: $isPresented) {
            ProgressDialogView(label: .constant("Updating firmware..."), progressUpdate: $progressUpdate)
        }
        .alert(item: $errorMessage) {
            Alert(
                title: Text("Firmware Update Failure"),
                message: Text($0.message),
                dismissButton: .default(Text("OK")))
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
                warnings: ["T48 support is experimental"])))
}
