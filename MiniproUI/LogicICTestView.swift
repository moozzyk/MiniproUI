//
//  LogicICTestView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/7/25.
//

import SwiftUI

struct LogicICTestView: View {
    @Binding var supportedDevices: [String]

    var body: some View {
        VStack {
            SearchableListView(items: $supportedDevices)
        }.task {
            supportedDevices = (try? await MiniproAPI.getSupportedDevices()) ?? []
        }
    }
}

#Preview {
    LogicICTestView(supportedDevices: .constant(["7400", "7404", "PIC16LF505"]))
}
