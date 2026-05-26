//
//  LogicICTestView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/7/25.
//

import SwiftUI

struct LogicICTestView: View {
    @ObservedObject var model: MiniproModel
    @State private var selectedDevice: String? = nil
    @State private var errorMessage: DialogErrorMessage? = nil

    var body: some View {
        let needsAlgorithms = AlgorithmXmlUtils.needsAlgorithmInstallation(programmerInfo: model.programmerInfo)
        let supportedLogicICs = model.supportedDevices?.logicICs ?? []
        VStack(alignment: .leading, spacing: 16) {
            TabHeaderView(
                caption: "Selected Logic IC: " + (model.logicICDetails?.name ?? "None"),
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
                        isCollapsible: false
                    )
                    .frame(maxWidth: 300)
                    .padding(20)
                    VStack {
                        if let logicICDetails = model.logicICDetails {
                            DeviceDetailsView(expectLogicChip: true, deviceDetails: $model.logicICDetails)
                            Button("Test") {
                                Task {
                                    do {
                                        let algorithmXmlPath = try AlgorithmXmlUtils.resolveAlgorithmXmlPath(
                                            programmerInfo: model.programmerInfo
                                        )
                                        model.logicICTestResult = try await MiniproAPI.testLogicIC(
                                            device: logicICDetails.name,
                                            algorithmXmlPath: algorithmXmlPath
                                        )
                                    } catch {
                                        errorMessage = .init(message: error.localizedDescription)
                                        model.logicICTestResult = nil
                                    }
                                }
                            }
                            .disabled(!(model.logicICDetails?.isLogicChip ?? true))
                            if model.logicICTestResult == nil {
                                Spacer()
                            }
                        }
                        LogicICTestResultView(logicICTestResult: $model.logicICTestResult)
                        Spacer()
                    }
                }
            }
        }.task {
            model.programmerInfo = try? await MiniproAPI.getProgrammerInfo()
            if let programmerInfo = model.programmerInfo {
                let infoicPath = InfoICUtils.resolveInfoICPath(for: programmerInfo.model)
                model.supportedDevices = try? await MiniproAPI.getSupportedDevices(infoicPath: infoicPath)
            }
        }.onChange(of: selectedDevice) {
            Task {
                if let device = selectedDevice, let programmerInfo = model.programmerInfo {
                    let infoicPath = InfoICUtils.resolveInfoICPath(for: programmerInfo.model)
                    model.logicICDetails = try? await MiniproAPI.getDeviceDetails(
                        device: device,
                        infoicPath: infoicPath
                    )
                }
                model.logicICTestResult = nil
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
    LogicICTestView(model: MiniproModel())
}
