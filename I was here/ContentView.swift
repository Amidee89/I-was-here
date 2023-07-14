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
import CoreGPX

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
            Button("Select GPX Folder or files") {
                isPickerPresented = true
            }
        }
        .fileImporter(
            isPresented: $isPickerPresented,
            allowedContentTypes: [.folder, .gpx],
            allowsMultipleSelection: true
        ) { result in
            do {
                   let urls = try result.get()
                   processFiles(at: urls)
               }
            catch {
                   // Handle failure cases here
               }
        }
    }
}

func processFiles(at urls: [URL]) {
    for url in urls {
        if url.pathExtension == "gpx" {
            processGPXFile(at: url)
        } else if url.hasDirectoryPath {
            processFilesInFolder(at: url)
        }
    }
}

func processGPXFile(at url: URL) {
    do {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        if let fileSize = fileAttributes[FileAttributeKey.size] as? NSNumber {
            print("File size: \(fileSize.intValue) bytes")
        }
    } catch {
        print("Failed to get file size for \(url.path)")
    }

    if let gpx = GPXParser(withURL: url)?.parsedData() {
        let trackCount = gpx.tracks.count
        print("Number of tracks: \(trackCount)")

        for (index, track) in gpx.tracks.enumerated() {
            let trackpointsCount = track.tracksegments.flatMap { $0.trackpoints }.count
            print("Track \(index + 1) has \(trackpointsCount) trackpoints")
        }
    }
}

func processFilesInFolder(at url: URL) {
    let fileManager = FileManager.default
    do {
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        let gpxFiles = contents.filter { $0.pathExtension == "gpx" }
        processFiles(at: gpxFiles)
    } catch {
        // Handle failure to read the directory here
    }
}

