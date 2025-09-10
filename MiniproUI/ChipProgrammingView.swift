//
//  ChipProgrammingView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/27/25.
//

import SwiftUI

struct DialogErrorMessage: Identifiable {
    var id: String { message }
    let message: String
}

struct ChipProgrammingView: View {
    @Binding var supportedDevices: SupportedDevices?
    @Binding var deviceDetails: DeviceDetails?
    @Binding var buffer: Data?
    @State private var selectedDevice: String?
    @State private var errorMessage: DialogErrorMessage?
    @State private var progressMessage: String? = nil

    private var showProgress: Bool { progressMessage != nil }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                TabHeaderView(
                    caption: "Selected Chip: " + (selectedDevice ?? "None"),
                    systemImageName: "memorychip.fill")
                HStack {
                    VStack {
                        BinaryDataView(data: $buffer)
                            .frame(minWidth: 658)
                        HStack {
                            OpenFileButton(caption: "Open File") { url in
                                buffer = try Data(contentsOf: url)
                            }
                            SaveFileButton { url in
                                try buffer?.write(to: url)
                            }
                            .disabled(buffer == nil)
                        }
                        Spacer()
                    }
                    VStack {
                        ReadChipButton(device: deviceDetails, buffer: $buffer, progressMessage: $progressMessage)
                        WriteChipButton(device: deviceDetails, buffer: buffer, progressMessage: $progressMessage)
                    }
                    let supportedEEPROMs = supportedDevices?.eepromICs ?? []
                    if supportedEEPROMs.isEmpty {
                        VStack {
                            Form {
                                ProgrammerNotConnected()
                            }
                            .formStyle(.grouped)
                            .padding(.top, 32)
                        }
                    } else {
                        ZStack {
                            VStack {
                                if deviceDetails != nil {
                                    DeviceDetailsView(expectLogicChip: false, deviceDetails: $deviceDetails)
                                        .padding(.top, 32)
                                    Spacer()
                                }
                            }
                            VStack {
                                SearchableListView(
                                    items: supportedEEPROMs, selectedItem: $selectedDevice,
                                    isCollapsible: true
                                )
                                .frame(maxWidth: 658, maxHeight: 600)
                                .padding([.trailing])
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                Spacer()
            }
            .disabled(showProgress)
            .blur(radius: showProgress ? 2 : 0)
            if showProgress {
                ProgressDialogView(label: progressMessage)
            }
        }
        .task {
            supportedDevices = try? await MiniproAPI.getSupportedDevices()
        }
        .onAppear() {
            selectedDevice = deviceDetails?.name
        }
        .onChange(of: selectedDevice) {
            Task {
                if let device = selectedDevice {
                    deviceDetails = try? await MiniproAPI.getDeviceDetails(device: device)
                }
            }
        }
    }
}

struct ReadChipButton: View {
    let device: DeviceDetails?
    @Binding var buffer: Data?
    @Binding var progressMessage: String?
    @State private var errorMessage: DialogErrorMessage?

    var body: some View {
        Button(" << ") {
            if let device = device {
                progressMessage = "Reading Chip Contents..."
                Task {
                    do {
                        buffer = try await MiniproAPI.read(device: device.name)
                    } catch {
                        errorMessage = .init(message: error.localizedDescription)
                    }
                    progressMessage = nil
                }
            }
        }
        .disabled(device?.isLogicChip ?? true)
        .alert(item: $errorMessage) {
            Alert(
                title: Text("Reading Chip Contents Failed"),
                message: Text($0.message),
                dismissButton: .default(Text("OK")))
        }
    }
}

struct WriteChipButton: View {
    let device: DeviceDetails?
    let buffer: Data?
    @Binding var progressMessage: String?
    @State private var errorMessage: DialogErrorMessage?

    var body: some View {
        Button(" >> ") {
            if let device = device, let buffer = buffer {
                progressMessage = "Writing Buffer Data..."
                Task {
                    do {
                        try await MiniproAPI.write(device: device.name, data: buffer, options: WriteOptions())
                    } catch {
                        errorMessage = .init(message: error.localizedDescription)
                    }
                    progressMessage = nil
                }
            }
        }
        .disabled(device?.isLogicChip ?? true || buffer == nil)
        .alert(item: $errorMessage) {
            Alert(
                title: Text("Write Failure"),
                message: Text($0.message),
                dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ChipProgrammingView(supportedDevices: .constant(nil), deviceDetails: .constant(nil), buffer: .constant(nil))
}
