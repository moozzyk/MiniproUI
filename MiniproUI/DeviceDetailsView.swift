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
                if let deviceDetails = deviceDetails {
                    Section(header: Text("\(deviceDetails.name) Details")) {
                        ForEach(deviceDetails.deviceInfo, id: \.self) { info in
                            PropertyRow(label: info.key, value: info.value)
                        }
                        if !(deviceDetails.isLogicChip) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                                Text("\(deviceDetails.name) is not a logic chip")
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .frame(height: computeHeight())
        }
    }

    private func computeHeight() -> CGFloat {
        if let deviceDetails = deviceDetails {
            if !deviceDetails.isLogicChip {
                return 400
            }
            return 220
        }
        return 0
    }
}

#Preview {
    DeviceDetailsView(
        deviceDetails: .constant(DeviceDetails(name: "7400", deviceInfo: [], programmingInfo: [], isLogicChip: true)))
}
