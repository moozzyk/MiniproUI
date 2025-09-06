//
//  LogicICTestView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/7/25.
//

import SwiftUI

struct LogicICTestView: View {
    @Binding var supportedLogicICs: [String]
    @State private var selectedDevice: String? = nil
    @State private var deviceDetails: DeviceDetails? = nil
    @State private var logicICTestResult: LogicICTestResult? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TabHeaderView(
                caption: "Selected Logic IC: " + (deviceDetails?.name ?? "None"),
                systemImageName: "flask.fill")
            if supportedLogicICs.isEmpty {
                Form {
                    ProgrammerNotConnected()
                }.formStyle(.grouped)
            } else {
                HStack {
                    SearchableListView(items: $supportedLogicICs, selectedItem: $selectedDevice, isCollapsible: false)
                        .frame(maxWidth: 300)
                        .padding(20)
                    VStack {
                        if deviceDetails != nil {
                            DeviceDetailsView(expectLogicChip: true, deviceDetails: $deviceDetails)
                            Button("Test") {
                                Task {
                                    logicICTestResult = try? await MiniproAPI.testLogicIC(
                                        device: deviceDetails!.name)
                                }
                            }
                            .disabled(!(deviceDetails?.isLogicChip ?? true))
                            if logicICTestResult == nil {
                                Spacer()
                            }
                        }
                        LogicICTestResultView(logicICTestResult: $logicICTestResult)
                        Spacer()
                    }
                }
            }
        }.task {
            supportedLogicICs = (try? await MiniproAPI.getSupportedDevices())?.logicICs ?? []
        }.onChange(of: selectedDevice) {
            Task {
                if let device = selectedDevice {
                    deviceDetails = try? await MiniproAPI.getDeviceDetails(device: device)
                }
                logicICTestResult = nil
            }
        }
    }
}

#Preview {
    LogicICTestView(supportedLogicICs: .constant(["7400", "7404", "PIC16LF505"]))
}
