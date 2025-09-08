//
//  LogicICTestView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/7/25.
//

import SwiftUI

struct LogicICTestView: View {
    @Binding var supportedDevices: SupportedDevices?
    @Binding var logicICDetails: DeviceDetails?
    @Binding var logicICTestResult: LogicICTestResult?
    @State private var selectedDevice: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TabHeaderView(
                caption: "Selected Logic IC: " + (logicICDetails?.name ?? "None"),
                systemImageName: "flask.fill")
            let supportedLogicICs = supportedDevices?.logicICs ?? []
            if supportedLogicICs.isEmpty {
                Form {
                    ProgrammerNotConnected()
                }.formStyle(.grouped)
            } else {
                HStack {
                    SearchableListView(items: supportedLogicICs, selectedItem: $selectedDevice, isCollapsible: false)
                        .frame(maxWidth: 300)
                        .padding(20)
                    VStack {
                        if logicICDetails != nil {
                            DeviceDetailsView(expectLogicChip: true, deviceDetails: $logicICDetails)
                            Button("Test") {
                                Task {
                                    logicICTestResult = try? await MiniproAPI.testLogicIC(
                                        device: logicICDetails!.name)
                                }
                            }
                            .disabled(!(logicICDetails?.isLogicChip ?? true))
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
            supportedDevices = try? await MiniproAPI.getSupportedDevices()
        }.onChange(of: selectedDevice) {
            Task {
                if let device = selectedDevice {
                    logicICDetails = try? await MiniproAPI.getDeviceDetails(device: device)
                }
                logicICTestResult = nil
            }
        }
    }
}

#Preview {
    LogicICTestView(
        supportedDevices: .constant(nil), logicICDetails: .constant(nil),
        logicICTestResult: .constant(nil))
}
