//
//  ContentView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 1/16/25.
//

import SwiftUI

enum ViewType: String, Hashable, CaseIterable {
    case epromProgramming = "Chip Programming"
    case logicIcTest = "Logic IC Test"
    case programmerInfo = "Programmer Information"
    case settings = "Settings"
    case visualMiniproInfo = "About Visual Minipro"
}

class MiniproModel: ObservableObject {
    @Published var programmerInfo: ProgrammerInfo?
    @Published var logicICDetails: DeviceDetails?
    @Published var logicICTestResult: LogicICTestResult?
    @Published var visualMiniproInfo: VisualMiniproInfo?
    @Published var supportedDevices: SupportedDevices? = SupportedDevices(logicICs: [], eepromICs: ["Loading..."])
    @Published var deviceDetails: DeviceDetails?
    @Published var buffer: Data?
    @Published var writeOptions = WriteOptions()
}

struct ContentView: View {
    @State private var selectedItem: ViewType = .epromProgramming
    @StateObject private var model = MiniproModel()

    var body: some View {
        NavigationSplitView {
            List(ViewType.allCases, id: \.self, selection: $selectedItem) { item in
                Text(item.rawValue)
            }.task {
                model.supportedDevices = try? await MiniproAPI.getSupportedDevices()
                model.programmerInfo = try? await MiniproAPI.getProgrammerInfo()
                model.visualMiniproInfo = try? await MiniproAPI.getVisualMiniproInfo()
            }
        } detail: {
            if selectedItem == .programmerInfo {
                ProgrammerInfoView(programmerInfo: $model.programmerInfo)
                    .navigationTitle(selectedItem.rawValue)
            } else if selectedItem == .logicIcTest {
                LogicICTestView(
                    supportedDevices: $model.supportedDevices, logicICDetails: $model.logicICDetails,
                    logicICTestResult: $model.logicICTestResult
                )
                .navigationTitle(selectedItem.rawValue)
            } else if selectedItem == .epromProgramming {
                ChipProgrammingView(
                    supportedDevices: $model.supportedDevices, deviceDetails: $model.deviceDetails,
                    buffer: $model.buffer,
                    writeOptions: $model.writeOptions
                )
                .navigationTitle(selectedItem.rawValue)
            } else if selectedItem == .visualMiniproInfo {
                VisualMiniproInfoView(visualMiniproInfo: $model.visualMiniproInfo)
                    .navigationTitle(selectedItem.rawValue)
            } else if selectedItem == .settings {
                SettingsView()
                    .navigationTitle(selectedItem.rawValue)
            } else {
                VisualMiniproInfoView(visualMiniproInfo: $model.visualMiniproInfo)
                    .navigationTitle(selectedItem.rawValue)
            }
        }
    }
}

#Preview {
    ContentView()
}
