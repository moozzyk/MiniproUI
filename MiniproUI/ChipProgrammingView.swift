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
                        ReadChipButton(device: deviceDetails, buffer: $buffer)
                        WriteChipButton(device: deviceDetails, buffer: buffer)
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
        }
        .task {
            supportedDevices = try? await MiniproAPI.getSupportedDevices()
        }
        .onAppear {
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
    @State private var progressUpdate: ProgressUpdate? = nil
    @State private var errorMessage: DialogErrorMessage?
    @State private var isPresented = false

    var body: some View {
        Button(" << ") {
            if let device = device {
                isPresented = true
                Task {
                    do {
                        buffer = try await MiniproAPI.read(device: device.name) {
                            progressUpdate = $0
                        }
                    } catch {
                        errorMessage = .init(message: error.localizedDescription)
                    }
                    progressUpdate = ProgressUpdate(operation: "", percentage: 100)
                    await Task.yield()
                    try await Task.sleep(nanoseconds: 1000 * 1_000_000)
                    isPresented = false
                    progressUpdate = nil
                }
            }
        }
        .disabled(device?.isLogicChip ?? true)
        .sheet(isPresented: $isPresented) {
            ModalDialogView {
                ProgressBarView(label: .constant("Reading Chip Contents..."), progressUpdate: $progressUpdate)
            }
        }
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
    @State private var isPresented = false

    var body: some View {
        Button(" >> ") {
            isPresented = device != nil && buffer != nil
        }
        .disabled(device?.isLogicChip ?? true || buffer == nil)
        .sheet(isPresented: $isPresented) {
            ModalDialogView {
                WriteChipView(device: device!, buffer: buffer!, isPresented: $isPresented)
                    .frame(width: 300, height: 100)
            }
        }
    }
}

#Preview {
    ChipProgrammingView(supportedDevices: .constant(nil), deviceDetails: .constant(nil), buffer: .constant(nil))
}
