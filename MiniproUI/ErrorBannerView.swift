//
//  ErrorBannerView.swift
//  MiniproUI
//
import SwiftUI

struct ErrorBanner: View {
    let errorMessage: String

    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            Text(errorMessage)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    ErrorBanner(errorMessage: "No programmer connected.")
}
