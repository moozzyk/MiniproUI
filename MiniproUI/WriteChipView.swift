//
//  WriteChipView.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 9/23/25.
//

import SwiftUI

enum WriteChipState {
    case writeOptions
    case writingData
}

struct WriteChipView: View {
    let device: DeviceDetails
    let buffer: Data
    @Binding var isPresented: Bool
    @Binding var writeOptions: WriteOptions
    @Binding var errorMessage: DialogErrorMessage?
    @State private var writeChipState = WriteChipState.writeOptions
    @State private var progressUpdate: ProgressUpdate?
    @State private var progressMessage: String?

    var body: some View {
        VStack {
            if writeChipState == .writeOptions {
                Spacer()
                WriteOptionsView(writeOptions: $writeOptions)
                Spacer()
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    Button("Write") {
                        progressMessage = "Writing Chip Contents..."
                        Task {
                            do {
                                try await MiniproAPI.write(device: device.name, data: buffer, options: writeOptions) {
                                    if $0.operation.contains("Reading") {
                                        progressMessage = "Verifying Data..."
                                    }
                                    progressUpdate = $0
                                }
                            } catch {
                                errorMessage = .init(message: error.localizedDescription)
                            }
                            progressUpdate = ProgressUpdate(operation: "", percentage: 100)
                            await Task.yield()
                            try await Task.sleep(nanoseconds: 1000 * 1_000_000)
                            isPresented = false
                            progressUpdate = nil
                        }
                        writeChipState = .writingData
                    }
                    .keyboardShortcut(.defaultAction)
                }
                Spacer()
            } else {
                ProgressBarView(label: $progressMessage, progressUpdate: $progressUpdate)
            }
        }
    }
}

struct ToggleWithWarning: View {
    let caption: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack {
                Text(caption)
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .opacity(isOn ? 1 : 0)
            }
        }
    }
}

struct WriteOptionsView: View {
    @Binding var writeOptions: WriteOptions

    var body: some View {
        Form {
            ToggleWithWarning(caption: "Ignore file size mismatch", isOn: $writeOptions.ignoreFileSizeMismatch)
            ToggleWithWarning(caption: "Ignore chip ID mismatch", isOn: $writeOptions.ignoreChipIdMismatch)
        }
    }
}
