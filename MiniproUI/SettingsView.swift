//
//  SettingsView.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 10/13/25.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                TabHeaderView(
                    caption: "Settings",
                    systemImageName: "gearshape.fill")
                FavoriteChipsView()
            }
        }.frame(minWidth: 400, minHeight: 500)
    }
}

#Preview {
    SettingsView()
}
