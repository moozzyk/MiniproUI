//
//  FileButtons.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 6/1/25.
//

import SwiftUI
import UniformTypeIdentifiers

enum OpenFileMode {
    case overwrite, append
}

private class OpenFileModeSelection: NSObject {
    var mode = OpenFileMode.overwrite

    func makeView() -> NSView {
        let overwrite = NSButton(radioButtonWithTitle: "Overwrite Buffer", target: self, action: #selector(modeChanged))
        let append = NSButton(radioButtonWithTitle: "Append to Buffer", target: self, action: #selector(modeChanged))
        append.tag = 1
        overwrite.state = .on
        let stack = NSStackView(views: [overwrite, append])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false

        let container = NSView()
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(
                item: stack, attribute: .leading, relatedBy: .equal,
                toItem: container, attribute: .trailing, multiplier: 0.25, constant: 0),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
        ])
        return container
    }

    @objc private func modeChanged(_ sender: NSButton) {
        mode = sender.tag == 1 ? .append : .overwrite
    }
}

struct OpenFileButton: View {
    @State private var errorMessage: DialogErrorMessage?
    private let caption: String
    private let fileTypes: [String]?
    private let showsOpenMode: Bool
    private let action: (URL, OpenFileMode) throws -> Void

    init(
        caption: String, fileTypes: [String]? = nil, showsOpenMode: Bool = false,
        action: @escaping (URL, OpenFileMode) throws -> Void
    ) {
        self.caption = caption
        self.fileTypes = fileTypes
        self.showsOpenMode = showsOpenMode
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
            let modeSelection = OpenFileModeSelection()
            if showsOpenMode {
                openPanel.accessoryView = modeSelection.makeView()
                openPanel.isAccessoryViewDisclosed = true
            }
            if openPanel.runModal() == .OK {
                do {
                    try action(openPanel.url!, modeSelection.mode)
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
