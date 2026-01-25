//
//  OptionToggleRow.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 1/25/26.
//

import SwiftUI

struct OptionToggleRow: View {
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
