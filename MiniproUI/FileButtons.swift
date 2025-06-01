//
//  FileButtons.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 6/1/25.
//

import SwiftUI


struct OpenFileButton: View {
    @State private var errorMessage: DialogErrorMessage?
    private let action: (URL) throws -> Void

    init(_ action: @escaping (URL) throws -> Void) {
        self.action = action
    }

    var body: some View {
        Button("Open File") {
            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            if openPanel.runModal() == .OK {
                do {
                    try action(openPanel.url!)
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
    @State private var errorMessage: DialogErrorMessage?
    private let action: (URL) throws -> Void

    init(_ action: @escaping (URL) throws -> Void) {
        self.action = action
    }

    var body: some View {
        Button("Save As") {
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.isExtensionHidden = false
            if savePanel.runModal() == .OK {
                do {
                    try action(savePanel.url!)
                } catch {
                    errorMessage = .init(message: error.localizedDescription)
                }
            }
        }
        .alert(item: $errorMessage) {
            Alert(
                title: Text("Error saving file"), message: Text($0.message),
                dismissButton: .default(Text("OK")))
        }
    }
}
