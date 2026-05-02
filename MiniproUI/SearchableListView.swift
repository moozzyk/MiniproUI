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
    @Binding var applyAdditionalFilter: Bool
    @State var selectedListItem: String?
    @State var searchText: String = ""
    @State var shouldShowList = true
    let isCollapsible: Bool
    let additionalFilter: (([String]) -> [String])?
    @Environment(\.colorScheme) private var colorScheme

    init(items: [String], selectedItem: Binding<String?>, isCollapsible: Bool) {
        self.items = items
        self._selectedItem = selectedItem
        self._applyAdditionalFilter = .constant(false)
        self.isCollapsible = isCollapsible
        self.additionalFilter = nil
        self._searchText = State(initialValue: selectedItem.wrappedValue ?? "")
        self._shouldShowList = State(initialValue: selectedItem.wrappedValue == nil || !isCollapsible)
    }

    init(
        items: [String], selectedItem: Binding<String?>, applyAdditionalFilter: Binding<Bool>,
        isCollapsible: Bool, additionalFilter: @escaping ([String]) -> [String]
    ) {
        self.items = items
        self._selectedItem = selectedItem
        self._applyAdditionalFilter = applyAdditionalFilter
        self.isCollapsible = isCollapsible
        self.additionalFilter = additionalFilter
        self._searchText = State(initialValue: selectedItem.wrappedValue ?? "")
        self._shouldShowList = State(initialValue: selectedItem.wrappedValue == nil || !isCollapsible)
    }

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

    private var listHeight: CGFloat {
        let rowHeight: CGFloat = 24
        let headerHeight: CGFloat = 44
        // Allow a few more rows before scrolling so the dropdown feels less cramped.
        let maxHeight: CGFloat = 320
        return min(maxHeight, headerHeight + CGFloat(max(filteredItems.count - 1, 0)) * rowHeight)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Text("Select IC")
                    .font(.headline)
                    .padding(.leading, 8)
                Spacer()
                SearchBar(searchText: $searchText)
                if additionalFilter != nil {
                    Toggle("Apply favorite chips filter", isOn: $applyAdditionalFilter)
                        .labelsHidden()
                        .help(Text("Apply favorite chips filter"))
                }
            }
            if shouldShowList && filteredItems.count > 0 {
                List(filteredItems, id: \.self, selection: $selectedListItem) { item in
                    Text(item)
                        .padding(.leading, 6)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                )
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.25 : 0.08), radius: 6, x: 0, y: 2)
                .frame(maxHeight: listHeight)
                .padding(.horizontal, 6)
            }
            Spacer()
        }.onChange(of: selectedListItem) {
            if selectedListItem != nil {
                selectedItem = selectedListItem
                if isCollapsible {
                    searchText = selectedListItem ?? ""
                    shouldShowList = false
                    selectedListItem = nil
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
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .frame(height: 22)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
        )
    }
}

#Preview {
    SearchableListView(
        items: ["apple", "orange", "banana"],
        selectedItem: .constant(nil),
        isCollapsible: false
    )
}
