//
//  SettingsView.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 10/13/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var libusbDebugLogging = UserDefaults.standard.libusbDebugLogging

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                TabHeaderView(
                    caption: "Settings",
                    systemImageName: "gearshape.fill")
                Form {
                    FavoriteChipsView()
                    Section(header: Text("Diagnostics")) {
                        Toggle("Enable libusb debug logging", isOn: $libusbDebugLogging)
                            .toggleStyle(.switch)
                            .onChange(of: libusbDebugLogging) { _, enabled in
                                UserDefaults.standard.libusbDebugLogging = enabled
                                if enabled {
                                    setenv("LIBUSB_DEBUG", "4", 1)
                                } else {
                                    unsetenv("LIBUSB_DEBUG")
                                }
                            }
                    }
                }
                .formStyle(.grouped)
            }
        }.frame(minWidth: 400, minHeight: 500)
    }
}

#Preview {
    SettingsView()
}
