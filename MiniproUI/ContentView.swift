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
}

class MiniproModel: ObservableObject {
    @Published var programmerInfo: ProgrammerInfo?
    @Published var supportedDevices: [String] = []
}

struct ContentView: View {
    @State private var selectedItem: ViewType = .epromProgramming
    @StateObject private var model = MiniproModel()

    var body: some View {
        NavigationSplitView {
            List(ViewType.allCases, id: \.self, selection: $selectedItem) { item in
                Text(item.rawValue)
            }.task {
                model.supportedDevices = (try? await MiniproAPI.getSupportedDevices()) ?? []
                model.programmerInfo = try? await MiniproAPI.getProgrammerInfo()
            }
        } detail: {
            if selectedItem == .programmerInfo {
                ProgrammerInfoView(programmerInfo: $model.programmerInfo)
                    .navigationTitle(selectedItem.rawValue)
            } else if selectedItem == .logicIcTest {
                LogicICTestView(supportedDevices: $model.supportedDevices)
                    .navigationTitle(selectedItem.rawValue)
            } else {
                ChipProgrammingView(supportedDevices: $model.supportedDevices)
                    .navigationTitle(selectedItem.rawValue)
            }
        }
    }
}

#Preview {
    ContentView()
}

