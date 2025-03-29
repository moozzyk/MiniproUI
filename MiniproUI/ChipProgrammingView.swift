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
    @State private var buffer: Data?
    @State private var errorMessage: DialogErrorMessage?
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Image(systemName: "flask.fill")
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
            VStack {
                BinaryDataView(data: $buffer)
                HStack{
                    OpenFileButton(buffer: $buffer)
                }
            }
            Spacer()
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

#Preview {
    ChipProgrammingView(supportedDevices: .constant(["7400", "7404", "PIC16LF505"]))
}
