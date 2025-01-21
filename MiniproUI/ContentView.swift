//
//  ContentView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 1/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedItem: String = "Chip Programming"
    @State private var items = ["Chip Programming", "Logic IC Test", "Minipro status"]

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedItem) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
            }
        } detail : {
            if selectedItem == "Minipro status" {
                let result = invokeStatus()
                Text(result.stdErr)
                    .navigationTitle(selectedItem)
            } else {
                Text("Detail View for \(selectedItem)")
                    .navigationTitle(selectedItem)
            }
        }
    }
}

#Preview {
    ContentView()
}
