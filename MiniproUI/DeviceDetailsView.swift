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

    var body: some View {
        VStack(alignment: .leading) {
            Text("Device Details")

            ForEach((deviceDetails?.deviceInfo) ?? [], id: \.self) { info in
                Text("\(info.key): \(info.value)")
            }
        }.onChange(of: device) { (_, newDevice) in
            Task {
                if let device = newDevice {
                    deviceDetails = try? await MiniproAPI.getDeviceDetails(device: device)
                }
            }
        }
    }
}

#Preview {
    DeviceDetailsView(device: .constant("7400"))
}
