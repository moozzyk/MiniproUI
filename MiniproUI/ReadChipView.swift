//
//  ReadChipView.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 1/25/26.
//

import SwiftUI

enum ReadChipState {
    case readOptions
    case readingData
}

struct ReadChipView: View {
    let device: DeviceDetails
    @Binding var buffer: Data?
    @Binding var isPresented: Bool
    @Binding var readOptions: ReadOptions
    @Binding var errorMessage: DialogErrorMessage?
    @State private var readChipState = ReadChipState.readOptions
    @State private var progressUpdate: ProgressUpdate?
    @State private var progressMessage: String?
    @State private var newReadOptions: ReadOptions

    init(
        device: DeviceDetails, buffer: Binding<Data?>, isPresented: Binding<Bool>, readOptions: Binding<ReadOptions>,
        errorMessage: Binding<DialogErrorMessage?>
    ) {
        self.device = device
        self._buffer = buffer
        self._isPresented = isPresented
        self._readOptions = readOptions
        self._errorMessage = errorMessage
        newReadOptions = readOptions.wrappedValue
    }

    var body: some View {
        VStack {
            if readChipState == .readOptions {
                Spacer()
                ReadOptionsView(readOptions: $newReadOptions)
                Spacer()
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    Button("Read") {
                        readOptions = newReadOptions
                        progressMessage = "Reading Chip Contents..."
                        Task {
                            do {
                                buffer = try await MiniproAPI.read(
                                    device: device.name,
                                    algorithmXmlPath: nil,
                                    readOptions: readOptions
                                ) {
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
                        readChipState = .readingData
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

struct ReadOptionsView: View {
    @Binding var readOptions: ReadOptions

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Read Options")
                .font(.headline)
            VStack(alignment: .leading, spacing: 0) {
                OptionToggleRow(
                    title: "Ignore chip ID mismatch",
                    isOn: $readOptions.ignoreChipIdMismatch,
                    showWarning: true
                )
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            )
        }
        .padding(16)
    }
}
