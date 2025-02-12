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
        VStack(alignment: .leading) {
            PropertyRow(title: "Model ", value: programmerInfo?.model ?? "Unknown")
            PropertyRow(title: "Firmware Version ", value: programmerInfo?.firmwareVersion ?? "Unknown")
            PropertyRow(title: "Device Code ", value: programmerInfo?.deviceCode ?? "Unknown")
            PropertyRow(title: "Serial Number ", value: programmerInfo?.serialNumber ?? "Unknown")
            PropertyRow(title: "Manufactured Date", value: programmerInfo?.dateManufactured ?? "Unknown")
            PropertyRow(title: "USB Speed", value: programmerInfo?.usbSpeed ?? "Unknown")
            PropertyRow(title: "Supply Voltage", value: programmerInfo?.supplyVoltage ?? "Unknown")
        }
        .padding()
        .task {
            programmerInfo = try? await MiniproAPI.getProgrammerInfo()
        }
    }
}

struct PropertyRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
                .frame(width: 150, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
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
