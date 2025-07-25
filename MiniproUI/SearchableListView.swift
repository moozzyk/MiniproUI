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
    @State var shouldShowList = true
    let isCollapsible: Bool

    var filteredItems: [String] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("Select IC").font(.headline)
                    .padding(.leading, 8)
                Spacer()
                SearchBar(searchText: $searchText)
                    .padding(.leading, 32)
            }
            if shouldShowList && filteredItems.count > 0 {
                List(filteredItems, id: \.self, selection: $selectedItem) { item in
                    Text("  " + item)
                }
                .frame(maxHeight: CGFloat(44 + (filteredItems.count - 1) * 24))
            }
            Spacer()
        }.onChange(of: selectedItem) {
            if isCollapsible {
                if let selectedItem = selectedItem {
                    searchText = selectedItem
                    shouldShowList = false
                }
            }
        }.onChange(of: searchText) {
            if isCollapsible {
                shouldShowList = shouldShowList || searchText != selectedItem
            }
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
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

#Preview {
    SearchableListView(items: .constant(["apple", "orange", "banana"]), selectedItem: .constant(nil), isCollapsible: false)
}
