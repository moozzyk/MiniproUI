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
    @Binding var programmerInfo: ProgrammerInfo?
    @State private var selectedDevice: String? = nil
    @State private var errorMessage: DialogErrorMessage? = nil

    var body: some View {
        let needsAlgorithms = AlgorithmXmlUtils.needsAlgorithmInstallation(programmerInfo: programmerInfo)
        let supportedLogicICs = supportedDevices?.logicICs ?? []
        VStack(alignment: .leading, spacing: 16) {
            TabHeaderView(
                caption: "Selected Logic IC: " + (logicICDetails?.name ?? "None"),
                systemImageName: "flask.fill"
            )
            if needsAlgorithms {
                Form {
                    MissingAlgorithms()
                }.formStyle(.grouped)
            } else if supportedLogicICs.isEmpty {
                Form {
                    ProgrammerNotConnected()
                }.formStyle(.grouped)
            } else {
                HStack {
                    SearchableListView(
                        items: supportedLogicICs,
                        selectedItem: $selectedDevice,
                        isCollapsible: false,
                        additionalFilter: nil
                    )
                    .frame(maxWidth: 300)
                    .padding(20)
                    VStack {
                        if logicICDetails != nil {
                            DeviceDetailsView(expectLogicChip: true, deviceDetails: $logicICDetails)
                            Button("Test") {
                                Task {
                                    do {
                                        let algorithmXmlPath = try AlgorithmXmlUtils.resolveAlgorithmXmlPath(
                                            programmerInfo: programmerInfo
                                        )
                                        logicICTestResult = try await MiniproAPI.testLogicIC(
                                            device: logicICDetails!.name,
                                            algorithmXmlPath: algorithmXmlPath
                                        )
                                    } catch {
                                        errorMessage = .init(message: error.localizedDescription)
                                        logicICTestResult = nil
                                    }
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
            programmerInfo = try? await MiniproAPI.getProgrammerInfo()
            if let programmerInfo {
                let infoicPath = InfoICUtils.resolveInfoICPath(for: programmerInfo.model)
                supportedDevices = try? await MiniproAPI.getSupportedDevices(infoicPath: infoicPath)
            }
        }.onChange(of: selectedDevice) {
            Task {
                if let device = selectedDevice, let programmerInfo {
                    let infoicPath = InfoICUtils.resolveInfoICPath(for: programmerInfo.model)
                    logicICDetails = try? await MiniproAPI.getDeviceDetails(device: device, infoicPath: infoicPath)
                }
                logicICTestResult = nil
            }
        }.alert(item: $errorMessage) {
            Alert(
                title: Text("Logic IC Test Error"),
                message: Text($0.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    LogicICTestView(
        supportedDevices: .constant(nil),
        logicICDetails: .constant(nil),
        logicICTestResult: .constant(nil),
        programmerInfo: .constant(nil)
    )
}
