//
//  ErrorBannerView.swift
//  MiniproUI
//
import SwiftUI

struct ErrorBanner<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            content
                .padding()
            Spacer()
        }
    }
}

#Preview {
    ErrorBanner {
        Text("No programmer connected.")
    }
}
