//
//  FavoriteChipsView.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 11/1/25.
//

import SwiftUI

struct FavoriteChipsView: View {
    @State private var items: [String] = UserDefaults.standard.favoriteChips
    @State private var newItemText = ""

    var body: some View {
        Form {
            Section(
                header: Text("Favorite chips")
            ) {
                List {
                    ForEach(items.indices, id: \.self) { index in
                        HStack {
                            TextField("Chip name pattern...", text: $items[index])
                            Button {
                                items.remove(at: index)
                                updateFavoriteChips()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        TextField("Chip name pattern...", text: $newItemText)
                            .onSubmit {
                                addNewItem()
                            }
                            .textFieldStyle(.roundedBorder)
                        Button("Add") {
                            addNewItem()
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private func addNewItem() {
        if !newItemText.isEmpty {
            items.append(newItemText)
            updateFavoriteChips()
            newItemText = ""
        }
    }

    private func updateFavoriteChips() {
        UserDefaults.standard.favoriteChips = items
    }
}

#Preview {
    FavoriteChipsView()
}
