//
//  ChipProgrammingView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/27/25.
//

import SwiftUI

struct ChipProgrammingView: View {
    @ObservedObject var model: MiniproModel
    @State private var selectedDevice: String?

    init(model: MiniproModel) {
        self.model = model
        self._selectedDevice = State(initialValue: model.deviceDetails?.name)
    }

    var body: some View {
        let needsAlgorithms = AlgorithmXmlUtils.needsAlgorithmInstallation(programmerInfo: model.programmerInfo)
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                TabHeaderView(
                    caption: "Selected Chip: " + (selectedDevice ?? "None"),
                    systemImageName: "memorychip.fill"
                )
                HStack {
                    VStack {
                        BinaryDataView(data: $model.buffer)
                            .frame(minWidth: 678)
                        HStack {
                            OpenFileButton(caption: "Open File") { url in
                                model.buffer = try Data(contentsOf: url)
                            }
                            SaveFileButton { url in
                                try model.buffer?.write(to: url)
                            }
                            .disabled(model.buffer == nil)
                        }
                        Spacer()
                    }
                    VStack {
                        ReadChipButton(
                            device: model.deviceDetails,
                            buffer: $model.buffer,
                            readOptions: $model.readOptions,
                            programmerInfo: $model.programmerInfo
                        )
                        WriteChipButton(
                            device: model.deviceDetails,
                            buffer: model.buffer,
                            writeOptions: $model.writeOptions,
                            programmerInfo: $model.programmerInfo
                        )
                    }
                    let supportedEEPROMs = model.supportedDevices?.eepromICs ?? []
                    if needsAlgorithms {
                        VStack {
                            Form {
                                MissingAlgorithms()
                            }
                            .formStyle(.grouped)
                            .padding(.top, 32)
                        }
                    } else if model.programmerInfo == nil {
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
                                if model.deviceDetails != nil {
                                    DeviceDetailsView(expectLogicChip: false, deviceDetails: $model.deviceDetails)
                                        .padding(.top, 32)
                                    Spacer()
                                }
                            }
                            VStack {
                                SearchableListView(
                                    items: supportedEEPROMs,
                                    selectedItem: $selectedDevice,
                                    applyAdditionalFilter: $model.applyFavoriteFilter,
                                    isCollapsible: true,
                                    additionalFilter: filterFavoriteChips
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
            model.programmerInfo = try? await MiniproAPI.getProgrammerInfo()
            if let programmerInfo = model.programmerInfo {
                let infoicPath = InfoICUtils.resolveInfoICPath(for: programmerInfo.model)
                model.supportedDevices = try? await MiniproAPI.getSupportedDevices(infoicPath: infoicPath)
            }
        }
        .onChange(of: selectedDevice) {
            Task {
                if let device = selectedDevice, let programmerInfo = model.programmerInfo {
                    let infoicPath = InfoICUtils.resolveInfoICPath(for: programmerInfo.model)
                    model.deviceDetails = try? await MiniproAPI.getDeviceDetails(device: device, infoicPath: infoicPath)
                }
            }
        }
    }

    func filterFavoriteChips(_ supportedEEPROMs: [String]) -> [String] {
        let favoriteChips = UserDefaults.standard.favoriteChips
        let filteredChips = supportedEEPROMs.filter { eeprom in
            favoriteChips.contains { eeprom.lowercased().contains($0.lowercased()) }
        }
        return filteredChips.isEmpty ? supportedEEPROMs : filteredChips
    }
}

struct ReadChipButton: View {
    let device: DeviceDetails?
    @Binding var buffer: Data?
    @Binding var readOptions: ReadOptions
    @Binding var programmerInfo: ProgrammerInfo?
    @State private var errorMessage: DialogErrorMessage?
    @State private var isPresented = false

    var body: some View {
        Button(" << ") {
            isPresented = device != nil
        }
        .disabled(device?.isLogicChip ?? true)
        .sheet(isPresented: $isPresented) {
            ModalDialogView {
                ReadChipView(
                    device: device!,
                    buffer: $buffer,
                    isPresented: $isPresented,
                    readOptions: $readOptions,
                    programmerInfo: $programmerInfo,
                    errorMessage: $errorMessage
                )
            }
        }
        .alert(item: $errorMessage) {
            Alert(
                title: Text("Reading Chip Contents Failed"),
                message: Text($0.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct WriteChipButton: View {
    let device: DeviceDetails?
    let buffer: Data?
    @Binding var writeOptions: WriteOptions
    @Binding var programmerInfo: ProgrammerInfo?
    @State private var isPresented = false
    @State private var errorMessage: DialogErrorMessage?

    var body: some View {
        Button(" >> ") {
            isPresented = device != nil && buffer != nil
        }
        .disabled(device?.isLogicChip ?? true || buffer == nil)
        .sheet(isPresented: $isPresented) {
            ModalDialogView {
                WriteChipView(
                    device: device!,
                    buffer: buffer!,
                    isPresented: $isPresented,
                    writeOptions: $writeOptions,
                    programmerInfo: $programmerInfo,
                    errorMessage: $errorMessage
                )
            }
        }
        .alert(item: $errorMessage) {
            Alert(
                title: Text("Write Failure"),
                message: Text($0.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    ChipProgrammingView(model: MiniproModel())
}
