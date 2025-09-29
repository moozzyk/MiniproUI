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
    @State private var writeChipState = WriteChipState.writeOptions
    @State private var progressUpdate: ProgressUpdate?
    @State private var progressMessage: String?
    @State private var errorMessage: DialogErrorMessage?

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
                    .alert(item: $errorMessage) {
                        Alert(
                            title: Text("Write Failure"),
                            message: Text($0.message),
                            dismissButton: .default(Text("OK")))
                    }
                }
                Spacer()
            } else {
                ProgressBarView(label: $progressMessage, progressUpdate: $progressUpdate)
            }
        }
    }
}

struct WriteOptionsView: View {
    @Binding var writeOptions: WriteOptions

    var body: some View {
        Form {
            Toggle("Ignore file size mismatch", isOn: $writeOptions.ignoreFileSize)
            Toggle("Ignore chip ID mismatch", isOn: $writeOptions.ignoreChipIdMismatch)
        }
    }
}
