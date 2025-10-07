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
    @State private var newWriteOptions: WriteOptions

    init(
        device: DeviceDetails, buffer: Data, isPresented: Binding<Bool>, writeOptions: Binding<WriteOptions>,
        errorMessage: Binding<DialogErrorMessage?>
    ) {
        self.device = device
        self.buffer = buffer
        self._isPresented = isPresented
        self._writeOptions = writeOptions
        self._errorMessage = errorMessage
        newWriteOptions = writeOptions.wrappedValue
    }

    var body: some View {
        VStack {
            if writeChipState == .writeOptions {
                Spacer()
                WriteOptionsView(writeOptions: $newWriteOptions)
                Spacer()
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    Button("Write") {
                        writeOptions = newWriteOptions
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

struct WriteOptionsView: View {
    @Binding var writeOptions: WriteOptions

    var body: some View {
        Form {
            Section("Write Options") {
                VStack(alignment: .leading, spacing: 0) {
                    OptionToggleRow(
                        title: "Ignore file size mismatch",
                        isOn: $writeOptions.ignoreFileSizeMismatch,
                        showWarning: true
                    )
                    Divider()

                    OptionToggleRow(
                        title: "Ignore chip ID mismatch",
                        isOn: $writeOptions.ignoreChipIdMismatch,
                        showWarning: true
                    )
                    Divider()

                    OptionToggleRow(
                        title: "Skip verification after writing",
                        isOn: .constant(false),
                        showWarning: true
                    )
                    Divider()

                    OptionToggleRow(
                        title: "Unprotect chip before writing",
                        isOn: .constant(false),
                        showWarning: false
                    )
                    Divider()

                    OptionToggleRow(
                        title: "Protect chip after writing",
                        isOn: .constant(false),
                        showWarning: false
                    )
                }
            }
        }
        .toggleStyle(.checkbox)
        .formStyle(.grouped)
        .padding(.vertical, 2)
        .scrollContentBackground(.hidden)
        .background(Color(.windowBackgroundColor))
    }
}

private struct OptionToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let showWarning: Bool

    private let iconSlot: CGFloat = 18

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
                .opacity(isOn && showWarning ? 1 : 0)
                .frame(width: iconSlot, height: 16)
            Toggle(title, isOn: $isOn)
        }
        .padding(.vertical, 6)
    }
}
