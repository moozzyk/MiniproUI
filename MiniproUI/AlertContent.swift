//
//  AlertContent.swift
//  Visual Minipro
//

import SwiftUI

struct AlertContent: Hashable, Identifiable {
    let title: String
    let message: String

    var id: Self { self }
}

extension View {
    func alert(_ content: Binding<AlertContent?>) -> some View {
        alert(item: content) {
            Alert(title: Text($0.title), message: Text($0.message), dismissButton: .default(Text("OK")))
        }
    }
}
