//
//  MissingAlgorithmsView.swift
//  MiniproUI
//

import SwiftUI

struct MissingAlgorithms: View {
    var body: some View {
        ErrorBanner(
            errorMessage: "Additional setup required. Install missing artifacts in Programmer Info."
        )
    }
}

#Preview {
    MissingAlgorithms()
}
