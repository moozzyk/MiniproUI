//
//  ProgressDialogView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 4/15/25.
//

import SwiftUI

struct ProgressDialogView: View {
    @Binding var label: String?
    @Binding var progressUpdate: ProgressUpdate?

    var body: some View {
        VStack(spacing: 40) {
            let progress = Double(progressUpdate?.percentage ?? 0)/100
            ProgressView(value: progress) {
                if let label = label {
                    Text(label)
                }
            }
        }
        .frame(maxWidth: 200)
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    ProgressDialogView(
        label: .constant("Downloading Chip Contents..."),
        progressUpdate: .constant(ProgressUpdate(operation: "Writing Code", percentage: 20))
    )
}
