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
    @Binding var supportedDevices: [String]
    @State private var selectedDevice: String?
    @State private var buffer: Data?
    @State private var errorMessage: DialogErrorMessage?
    @State private var deviceDetails: DeviceDetails? = nil
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
                            OpenFileButton(buffer: $buffer)
                            SaveFileButton(buffer: $buffer)
                        }
                        Spacer()
                    }
                    VStack {
                        ReadChipButton(device: deviceDetails, buffer: $buffer, progressMessage: $progressMessage)
                        WriteChipButton(device: deviceDetails, buffer: buffer, progressMessage: $progressMessage)
                    }
                    if supportedDevices.isEmpty {
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
                                    items: $supportedDevices, selectedItem: $selectedDevice, isCollapsible: true
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
        .onChange(of: selectedDevice) {
            Task {
                if let device = selectedDevice {
                    deviceDetails = try? await MiniproAPI.getDeviceDetails(device: device)
                }
            }
        }
    }
}

struct OpenFileButton: View {
    @Binding var buffer: Data?
    @State private var errorMessage: DialogErrorMessage?

    var body: some View {
        Button("Open File") {
            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            if openPanel.runModal() == .OK {
                do {
                    buffer = try Data(contentsOf: openPanel.url!)
                } catch {
                    errorMessage = .init(message: error.localizedDescription)
                }
            }
        }.alert(item: $errorMessage) {
            Alert(
                title: Text("Error opening file"), message: Text($0.message),
                dismissButton: .default(Text("OK")))
        }
    }
}

struct SaveFileButton: View {
    @Binding var buffer: Data?
    @State private var errorMessage: DialogErrorMessage?

    var body: some View {
        Button("Save As") {
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.isExtensionHidden = false
            if savePanel.runModal() == .OK {
                do {
                    try buffer?.write(to: savePanel.url!)
                } catch {
                    errorMessage = .init(message: error.localizedDescription)
                }
            }
        }
        .disabled(buffer == nil)
        .alert(item: $errorMessage) {
            Alert(
                title: Text("Error saving file"), message: Text($0.message),
                dismissButton: .default(Text("OK")))
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
    ChipProgrammingView(supportedDevices: .constant(["7400", "7404", "PIC16LF505"]))
}
