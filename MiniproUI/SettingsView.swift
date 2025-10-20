//
//  SettingsView.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 10/13/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var items = ["Apple", "Banana", "Orange"]
    @State private var newItemText = ""

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                TabHeaderView(
                    caption: "Settings",
                    systemImageName: "gearshape.fill")
                VStack {
                    Text("Favorite chips")
                    List {
                        ForEach(items.indices, id: \.self) { index in
                            HStack {
                                TextField("Chip name pattern...", text: $items[index])
                                Button {
                                    items.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                }
                                .buttonStyle(.borderless)
                                .foregroundColor(.secondary)
                            }
                        }
                    }

                    HStack {
                        TextField("Chip name pattern...", text: $newItemText)
                            .onSubmit {
                                addNewItem()
                            }
                        Button("Add") {
                            addNewItem()
                        }
                    }
                }.padding()

                Spacer()
            }
        }.frame(minWidth: 400, minHeight: 500)
    }

    private func addNewItem() {
        if !newItemText.isEmpty {
            items.append(newItemText)
            newItemText = ""
        }
    }
}

#Preview {
    SettingsView()
}
