//
//  ProgrammerInfoView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/2/25.
//

import SwiftUI

struct ProgrammerInfoView: View {
    @Binding var programmerInfo: ProgrammerInfo?

    func getProgrammerName(_ programmerInfo: ProgrammerInfo?) -> String {
        let programmerModel = programmerInfo?.model
        if let model = programmerModel {
            return "Minipro \(model)"
        }
        return "Unknown"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TabHeaderView(
                caption: "Programmer: " + getProgrammerName(programmerInfo),
                secondaryCaption: programmerInfo?.firmwareVersion,
                systemImageName: "cpu.fill")
            Form {
                if programmerInfo?.model == nil {
                    ProgrammerNotConnected()
                } else {
                    Section {
                        PropertyRow(label: "Model ", value: programmerInfo?.model ?? "Unknown")
                        PropertyRow(label: "Firmware Version ", value: programmerInfo?.firmwareVersion ?? "Unknown")
                        PropertyRow(label: "Device Code ", value: programmerInfo?.deviceCode ?? "Unknown")
                        PropertyRow(label: "Serial Number ", value: programmerInfo?.serialNumber ?? "Unknown")
                        PropertyRow(label: "Manufactured Date", value: programmerInfo?.dateManufactured ?? "Unknown")
                        PropertyRow(label: "USB Speed", value: programmerInfo?.usbSpeed ?? "Unknown")
                        PropertyRow(label: "Supply Voltage", value: programmerInfo?.supplyVoltage ?? "Unknown")
                    }
                }

                if programmerInfo?.warnings.count ?? 0 > 0 {
                    Section(
                        header: HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Warnings")
                        }
                    ) {
                        ForEach (programmerInfo?.warnings ?? [], id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(minWidth: 400, minHeight: 500)
        .task {
            programmerInfo = try? await MiniproAPI.getProgrammerInfo()
        }
    }
}



#Preview {
    ProgrammerInfoView(
        programmerInfo: .constant(
            ProgrammerInfo(
                model: "T48",
                firmwareVersion: "00.1.31 (0x11f)",
                deviceCode: "46A16257",
                serialNumber: "HSSCVO9LARFMOYKYOMVE5123",
                dateManufactured: "2024-06-28 16:55",
                usbSpeed: "480Mbps (USB 2.0)",
                supplyVoltage: "5.11 V",
                warnings: ["T48 support is experimental"])))
}
