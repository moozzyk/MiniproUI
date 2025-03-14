//
//  LogicICTestView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/7/25.
//

import SwiftUI

struct LogicICTestView: View {
    @Binding var supportedDevices: [String]
    @State private var selectedDevice: String? = nil
    @State private var deviceDetails: DeviceDetails? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Image(systemName: "flask.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(.trailing, 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Logic IC " + (deviceDetails?.name ?? "None"))
                        .font(.title)
                        .fontWeight(.semibold)
                }
            }
            .padding([.top, .horizontal])
            Divider()
            if supportedDevices.isEmpty {
                Form {
                    ProgrammerNotConnected()
                }.formStyle(.grouped)
            } else {
                HStack {
                    SearchableListView(items: $supportedDevices, selectedItem: $selectedDevice)
                        .frame(maxWidth: 300)
                        .padding(16)
                    DeviceDetailsView(deviceDetails: $deviceDetails)
                        .frame(maxWidth: 350)
                    Spacer()
                }
            }
        }.task {
            supportedDevices = (try? await MiniproAPI.getSupportedDevices()) ?? []
        }.onChange(of: selectedDevice) {
            Task {
                if let device = selectedDevice {
                    deviceDetails = try? await MiniproAPI.getDeviceDetails(device: device)
                }
            }
        }
    }
}

#Preview {
    LogicICTestView(supportedDevices: .constant(["7400", "7404", "PIC16LF505"]))
}
