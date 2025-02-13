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

    var body: some View {
        HStack {
            SearchableListView(items: $supportedDevices, selectedItem: $selectedDevice)
            DeviceDetailsView(device: $selectedDevice)
        }.task {
            supportedDevices = (try? await MiniproAPI.getSupportedDevices()) ?? []
        }
    }
}

#Preview {
    LogicICTestView(supportedDevices: .constant(["7400", "7404", "PIC16LF505"]))
}
