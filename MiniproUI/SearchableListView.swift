//
//  SearchableListView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/8/25.
//

import SwiftUI

struct SearchableListView: View {
    @Binding var items: [String]
    @Binding var selectedItem: String?
    @State var searchText: String = ""

    var filteredItems: [String] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack {
            SearchBar(searchText: $searchText)
            List {
                ForEach(filteredItems.prefix(500), id: \.self) { item in
                    SelectableRow(item: item, selectedItem: $selectedItem)
                }
            }
        }
    }
}

struct SelectableRow: View {
    let item: String
    @Binding var selectedItem: String?

    var body: some View {
        HStack {
            Text(item)
            Spacer()
            if item == selectedItem {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedItem = item
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .frame(height: 28)
                    .foregroundColor(.red)
                HStack {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: $searchText)
                        .frame(height: 30)
                        .textFieldStyle(.plain)
                        .cornerRadius(6)
                }
                .background(.white)
                .cornerRadius(6)
            }
        }
    }
}

#Preview {
    SearchableListView(items: .constant(["apple", "orange", "banana"]), selectedItem: .constant(nil))
}
