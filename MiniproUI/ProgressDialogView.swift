//
//  ProgressDialogView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 4/15/25.
//

import SwiftUI

struct ProgressDialogView: View {
    let label: String?

    var body: some View {
        VStack(spacing: 40) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            if let label = label {
                Text(label)
            }
        }
        .padding(120)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    ProgressDialogView(label: "Downloading Chip Contents...")
}
