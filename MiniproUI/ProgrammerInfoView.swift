//
//  ProgrammerInfoView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/2/25.
//

import SwiftUI

struct ProgrammerInfoView: View {
    @Binding var programmerInfo: ProgrammerInfo?
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Image(systemName: "cpu.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(.trailing, 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Minipro " + (programmerInfo?.model ?? "Unknown"))
                        .font(.title)
                        .fontWeight(.semibold)
                    if programmerInfo?.model != nil {
                        Text(programmerInfo?.firmwareVersion ?? "")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding([.top, .horizontal])

            Divider()

            Form {
                if programmerInfo?.model == nil {
                    HStack {
                        Spacer()
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text("No programmer connected.")
                            .padding()
                        Spacer()
                    }
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
                        Text("Warning")
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

struct PropertyRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
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
                warnings: [])))
}
