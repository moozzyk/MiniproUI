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
    case visualMiniproInfo = "About Visual Minipro"
}

class MiniproModel: ObservableObject {
    @Published var programmerInfo: ProgrammerInfo?
    @Published var supportedLogicICs: [String] = []
    @Published var supportedEEPROMs: [String] = []
    @Published var logicICDetails: DeviceDetails?
    @Published var visualMiniproInfo: VisualMiniproInfo?
}

struct ContentView: View {
    @State private var selectedItem: ViewType = .epromProgramming
    @StateObject private var model = MiniproModel()

    var body: some View {
        NavigationSplitView {
            List(ViewType.allCases, id: \.self, selection: $selectedItem) { item in
                Text(item.rawValue)
            }.task {
                let supportedDevices = try? await MiniproAPI.getSupportedDevices()
                model.supportedLogicICs = supportedDevices?.logicICs ?? []
                model.supportedEEPROMs = supportedDevices?.eepromICs ?? []
                model.programmerInfo = try? await MiniproAPI.getProgrammerInfo()
                model.visualMiniproInfo = try? await MiniproAPI.getVisualMiniproInfo()
            }
        } detail: {
            if selectedItem == .programmerInfo {
                ProgrammerInfoView(programmerInfo: $model.programmerInfo)
                    .navigationTitle(selectedItem.rawValue)
            } else if selectedItem == .logicIcTest {
                LogicICTestView(supportedLogicICs: $model.supportedLogicICs, logicICDetails: $model.logicICDetails)
                    .navigationTitle(selectedItem.rawValue)
            } else if selectedItem == .epromProgramming {
                ChipProgrammingView(supportedEEPROMs: $model.supportedEEPROMs)
                    .navigationTitle(selectedItem.rawValue)
            } else if selectedItem == .visualMiniproInfo {
                VisualMiniproInfoView(visualMiniproInfo: $model.visualMiniproInfo)
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

