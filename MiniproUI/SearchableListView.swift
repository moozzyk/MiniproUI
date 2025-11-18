//
//  SearchableListView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/8/25.
//

import SwiftUI

struct SearchableListView: View {
    let items: [String]
    @Binding var selectedItem: String?
    @State var searchText: String = ""
    @State var shouldShowList = true
    @State var applyAdditionalFilter = true
    let isCollapsible: Bool
    let additionalFilter: (([String]) -> [String])?

    func prefilterItems() -> [String] {
        if additionalFilter != nil && applyAdditionalFilter {
            return additionalFilter!(items)
        }
        return items
    }

    var filteredItems: [String] {
        let prefilteredItems = self.prefilterItems()
        if searchText.isEmpty {
            return prefilteredItems
        } else {
            return prefilteredItems.filter { $0.localizedCaseInsensitiveContains(searchText) }
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
                if additionalFilter != nil {
                    Toggle("Apply favorite chips filter", isOn: $applyAdditionalFilter)
                        .labelsHidden()
                        .help(Text("Apply favorite chips filter"))
                }
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
    SearchableListView(
        items: ["apple", "orange", "banana"], selectedItem: .constant(nil), isCollapsible: false, additionalFilter: nil)
}
