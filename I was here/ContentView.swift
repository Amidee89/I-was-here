//
//  ContentView.swift
//  I was here
//
//  Created by Marco Carandente on 13.7.2023.
//

import SwiftUI
#if(macOS)
import AppKit
#elseif(iOS)
import UIKit
#endif
import UniformTypeIdentifiers

extension UTType {
    static var gpx: UTType {
        UTType(importedAs: "public.xml")
    }
}

struct ContentView: View {
    var body: some View {
        FilePickerView()
    }
}

struct FilePickerView: View {
    @State private var isPickerPresented = false
    var body: some View {
        VStack {
            Button("Select GPX Folder") {
                isPickerPresented = true
            }
        }
        .fileImporter(
            isPresented: $isPickerPresented,
            allowedContentTypes: [.folder, .gpx],
            allowsMultipleSelection: false
        ) { result in
            do {
                let folderURL = try result.get().first!
                // Do something with the selected folder URL
            } catch {
                // Handle failure cases here
            }
        }
    }
}

