//
//  I_was_hereApp.swift
//  I was here
//
//  Created by Marco Carandente on 13.7.2023.
//

import SwiftUI

@main
struct I_was_hereApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
        #endif
    }
}
