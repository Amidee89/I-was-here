//
//  GpxProcessor.swift
//  I was here
//
//  Created by Marco Carandente on 15.7.2023.
//

import Foundation
import CoreGPX
import SQLite

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
        createDB()
        for (index, track) in gpx.tracks.enumerated() {
            let trackpointsCount = track.segments.flatMap { $0.points }.count
            print("Track \(index + 1) has \(trackpointsCount) trackpoints")
        }
    }
}
