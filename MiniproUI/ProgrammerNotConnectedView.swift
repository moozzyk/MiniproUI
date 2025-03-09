//
//  ProgrammerNotConnectedView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/8/25.
//

import SwiftUI

struct ProgrammerNotConnected: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            Text("No programmer connected.")
                .padding()
            Spacer()
        }
    }
}

#Preview {
    ProgrammerNotConnected()
}
