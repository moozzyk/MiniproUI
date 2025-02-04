//
//  ContentView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 1/16/25.
//

import SwiftUI

enum ViewType: String, Hashable, CaseIterable {
    case epromProgramming = "Chip Programming"
    case logicIcTest = "Logic IC Test"
    case programmerInfo = "Programmer Information"
}

struct ContentView: View {
    @State private var selectedItem: ViewType = .epromProgramming

    var body: some View {
        NavigationSplitView {
            List(ViewType.allCases, id: \.self, selection: $selectedItem) { item in
                Text(item.rawValue)
            }
        } detail: {
            if selectedItem == .programmerInfo {
                MiniproAboutView()
                    .navigationTitle(selectedItem.rawValue)
            } else {
                Text("Detail View for \(selectedItem.rawValue)")
                    .navigationTitle(selectedItem.rawValue)
            }
        }
    }
}

#Preview {
    ContentView()
}
