//
//  ModalDialogView.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 9/27/25.
//

import SwiftUI

struct ModalDialogView <Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
    }
}
