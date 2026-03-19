//
//  MiniproUIApp.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 1/16/25.
//

import SwiftUI

@main
struct MiniproUIApp: App {
    init() {
        if UserDefaults.standard.libusbDebugLogging {
            setenv("LIBUSB_DEBUG", "4", 1)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
