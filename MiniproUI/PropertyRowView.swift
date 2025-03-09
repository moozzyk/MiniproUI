//
//  PropertyRowView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/8/25.
//

import SwiftUI

struct PropertyRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
