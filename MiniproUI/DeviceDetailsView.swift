//
//  DeviceDetailsView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/11/25.
//

import SwiftUI

struct DeviceDetailsView: View {
    @Binding var deviceDetails: DeviceDetails?

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
                            Text("Not a logic chip")
                                .fontWeight(.medium)
                        }
                    }
                }
            }.formStyle(.grouped)
        }
    }
}

#Preview {
    DeviceDetailsView(deviceDetails: .constant(DeviceDetails(deviceInfo: [], programmingInfo: [], isLogicChip: true)))
}
