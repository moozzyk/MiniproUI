//
//  FileButtons.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 6/1/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct OpenFileButton: View {
    @State private var errorMessage: DialogErrorMessage?
    private let caption: String
    private let fileTypes: [String]?
    private let action: (URL) throws -> Void

    init(caption: String, fileTypes: [String]? = nil, action: @escaping (URL) throws -> Void) {
        self.caption = caption
        self.fileTypes = fileTypes
        self.action = action
    }

    var body: some View {
        Button(caption) {
            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            if let fileTypes {
                let allowedTypes = fileTypes.compactMap {
                    UTType(tag: $0, tagClass: .filenameExtension, conformingTo: .data)
                }
                if !allowedTypes.isEmpty {
                    openPanel.allowedContentTypes = allowedTypes
                }
            }
            if openPanel.runModal() == .OK {
                do {
                    try action(openPanel.url!)
                } catch {
                    errorMessage = .init(message: error.localizedDescription)
                }
            }
        }.alert(item: $errorMessage) {
            Alert(
                title: Text("Error opening file"),
                message: Text($0.message),
                dismissButton: .default(Text("OK"))
            )
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
                title: Text("Error saving file"),
                message: Text($0.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
