//
//  ProgrammerNotConnectedView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/8/25.
//

import SwiftUI

struct ProgrammerNotConnected: View {
    var body: some View {
        ErrorBanner {
            Text("No programmer connected.")
        }
    }
}

#Preview {
    ProgrammerNotConnected()
}
