//
//  ChipProgrammingView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/27/25.
//

import SwiftUI

struct DialogErrorMessage: Identifiable {
    var id: String { message }
    let message: String
}

struct ChipProgrammingView: View {
    @Binding var supportedDevices: [String]
    @State private var selectedDevice: String?
    @State private var buffer: Data?
    @State private var errorMessage: DialogErrorMessage?
    @State private var deviceDetails: DeviceDetails? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Image(systemName: "memorychip.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(.trailing, 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Chip " + "None")
                        .font(.title)
                        .fontWeight(.semibold)
                }
            }
            .padding([.top, .horizontal])
            Divider()
            HStack {
                VStack {
                    BinaryDataView(data: $buffer)
                    HStack {
                        OpenFileButton(buffer: $buffer)
                        SaveFileButton(buffer: $buffer)
                    }
                    Spacer()
                }
                VStack {
                    Button("  <<  ") {}
                    Button("  >>  ") {}
                }
                ZStack {
                    VStack {
                        if deviceDetails != nil {
                            DeviceDetailsView(deviceDetails: $deviceDetails)
                                .padding(.top, 32)
                            Spacer()
                        }
                    }
                    VStack {
                        SearchableListView(items: $supportedDevices, selectedItem: $selectedDevice, isCollapsible: true)
                            .frame(maxWidth: 658, maxHeight: 600)
                            .padding([.trailing])
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        .onChange(of: selectedDevice) {
            Task {
                if let device = selectedDevice {
                    deviceDetails = try? await MiniproAPI.getDeviceDetails(device: device)
                }
            }
        }
    }
}

struct OpenFileButton: View {
    @Binding var buffer: Data?
    @State private var errorMessage: DialogErrorMessage?

    var body: some View {
        Button("Open File") {
            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            if openPanel.runModal() == .OK {
                do {
                    buffer = try Data(contentsOf: openPanel.url!)
                } catch {
                    errorMessage = .init(message: error.localizedDescription)
                }
            }
        }.alert(item: $errorMessage) {
            Alert(
                title: Text("Error opening file"), message: Text($0.message),
                dismissButton: .default(Text("OK")))
        }
    }
}

struct SaveFileButton: View {
    @Binding var buffer: Data?
    @State private var errorMessage: DialogErrorMessage?

    var body: some View {
        Button("Save As") {
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.isExtensionHidden = false
            if savePanel.runModal() == .OK {
                do {
                    try buffer?.write(to: savePanel.url!)
                } catch {
                    errorMessage = .init(message: error.localizedDescription)
                }
            }
        }
        .disabled(buffer == nil)
        .alert(item: $errorMessage) {
            Alert(
                title: Text("Error saving file"), message: Text($0.message),
                dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ChipProgrammingView(supportedDevices: .constant(["7400", "7404", "PIC16LF505"]))
}
