//
//  ProgressBarView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 4/15/25.
//

import SwiftUI

struct ProgressBarView: View {
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
    }
}

#Preview {
    ProgressBarView(
        label: .constant("Downloading Chip Contents..."),
        progressUpdate: .constant(ProgressUpdate(operation: "Writing Code", percentage: 20))
    )
}
