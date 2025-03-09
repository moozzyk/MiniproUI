//
//  DeviceDetailsView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/11/25.
//

import SwiftUI

struct DeviceDetailsView: View {
    @Binding var device: String?
    @State var deviceDetails: DeviceDetails?
    @State var deviceDisplayName: String?

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section (header: Text("IC Details")) {
                    ForEach((deviceDetails?.deviceInfo) ?? [], id: \.self) { info in
                        PropertyRow(label: info.key, value: info.value)
                    }
                    if !(deviceDetails?.isLogicChip ?? true) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("\(deviceDisplayName ?? "") is not a logic chip")
                                .fontWeight(.medium)
                        }
                    }
                }
            }.formStyle(.grouped)
        }.onChange(of: device) { (_, newDevice) in
            Task {
                if let device = newDevice {
                    deviceDetails = try? await MiniproAPI.getDeviceDetails(device: device)
                }
                deviceDisplayName = newDevice
            }
        }
    }
}

#Preview {
    DeviceDetailsView(device: .constant("7400"))
}
