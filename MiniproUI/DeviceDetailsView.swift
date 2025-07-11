//
//  DeviceDetailsView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/11/25.
//

import SwiftUI

struct DeviceDetailsView: View {
    let expectLogicChip: Bool
    @Binding var deviceDetails: DeviceDetails?

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                if let deviceDetails = deviceDetails {
                    Section(header: Text("\(deviceDetails.name) Details")) {
                        ForEach(deviceDetails.deviceInfo, id: \.self) { info in
                            PropertyRow(label: info.key, value: info.value)
                        }
                        if expectLogicChip != deviceDetails.isLogicChip {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                                Text(
                                    "\(deviceDetails.name) is not a \(expectLogicChip ? "logic" : "programmable") chip"
                                )
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
            return 220 + (expectLogicChip ? 0 : 30) // account for the additional warning row
        }
        return 0
    }
}

#Preview {
    DeviceDetailsView(
        expectLogicChip: true,
        deviceDetails: .constant(DeviceDetails(name: "7400", deviceInfo: [], programmingInfo: [], isLogicChip: true)))
}
