//
//  dbManager.swift
//  I was here
//
//  Created by Marco Carandente on 15.7.2023.
//

import Foundation
import SQLite
func createDB(){
    do {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        let db = try Connection("\(path)/iwh.sqlite3")
        print(db.description)
        // GPX Table
        let gpx = Table("gpx")
        let gpxID = Expression<Int64>("id")
        let version = Expression<String>("version")
        let creator = Expression<String>("creator")
        let importDate = Expression<Date>("importDate")
        try db.run(gpx.create { t in
            t.column(gpxID, primaryKey: .autoincrement)
            t.column(version)
            t.column(creator)
            t.column(importDate)
        })

        // Metadata Table
        let metadata = Table("metadata")
        let metadataID = Expression<Int64>("id")
        let gpxReference = Expression<Int64>("gpx_id")
        let name = Expression<String?>("name")
        let desc = Expression<String?>("desc")
        let time = Expression<Date?>("time")
        let keywords = Expression<String?>("keywords")
        // Other columns here
        try db.run(metadata.create { t in
            t.column(metadataID, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.column(name)
            t.column(desc)
            t.column(time)
            t.column(keywords)
            t.foreignKey(gpxReference, references: gpx, gpxID)
        })

        // Waypoints Table
        let waypoints = Table("waypoints")
        let waypointID = Expression<Int64>("id")
        let metadataReference = Expression<Int64>("metadata_id")
        let lat = Expression<Double>("lat")
        let lon = Expression<Double>("lon")
        let ele = Expression<Double?>("ele")
        let waypointTime = Expression<Date?>("time")
        let magvar = Expression<Double?>("magvar")
        // Other columns here
        try db.run(waypoints.create { t in
            t.column(waypointID, primaryKey: .autoincrement)
            t.column(metadataReference)
            t.column(lat)
            t.column(lon)
            t.column(ele)
            t.column(waypointTime)
            t.column(magvar)
            t.foreignKey(metadataReference, references: metadata, metadataID)
        })

        // Continue with other tables
        // Routes Table
        let routes = Table("routes")
        let routeID = Expression<Int64>("id")
        let gpxRefRoutes = Expression<Int64>("gpx_id")
        let nameRoutes = Expression<String?>("name")
        let descRoutes = Expression<String?>("desc")
        let typeRoutes = Expression<String?>("type")
        try db.run(routes.create { t in
            t.column(routeID, primaryKey: .autoincrement)
            t.column(gpxRefRoutes)
            t.column(nameRoutes)
            t.column(descRoutes)
            t.column(typeRoutes)
            t.foreignKey(gpxRefRoutes, references: gpx, gpxID)
        })

        // Tracks Table
        let tracks = Table("tracks")
        let trackID = Expression<Int64>("id")
        let gpxRefTracks = Expression<Int64>("gpx_id")
        let nameTracks = Expression<String?>("name")
        let descTracks = Expression<String?>("desc")
        let typeTracks = Expression<String?>("type")
        try db.run(tracks.create { t in
            t.column(trackID, primaryKey: .autoincrement)
            t.column(gpxRefTracks)
            t.column(nameTracks)
            t.column(descTracks)
            t.column(typeTracks)
            t.foreignKey(gpxRefTracks, references: gpx, gpxID)
        })
        
        // Extensions Table
        let extensions = Table("extensions")
        let extensionID = Expression<Int64>("id")
        let raw = Expression<String>("raw")
        try db.run(extensions.create { t in
            t.column(extensionID, primaryKey: .autoincrement)
            t.column(raw)
        })

        // TrackSegments Table
        let tracksegments = Table("tracksegments")
        let tracksegmentID = Expression<Int64>("id")
        let trackReference = Expression<Int64>("track_id")
        try db.run(tracksegments.create { t in
            t.column(tracksegmentID, primaryKey: .autoincrement)
            t.column(trackReference)
            t.foreignKey(trackReference, references: tracks, trackID)
        })

        // Copyright Table
        let copyright = Table("copyright")
        let copyrightID = Expression<Int64>("id")
        let authorCopyright = Expression<String>("author")
        let year = Expression<Int?>("year")
        let license = Expression<String?>("license")
        try db.run(copyright.create { t in
            t.column(copyrightID, primaryKey: .autoincrement)
            t.column(authorCopyright)
            t.column(year)
            t.column(license)
        })

        // Links Table
        let links = Table("links")
        let linkID = Expression<Int64>("id")
        let href = Expression<String>("href")
        let textLink = Expression<String?>("text")
        let typeLink = Expression<String?>("type")
        try db.run(links.create { t in
            t.column(linkID, primaryKey: .autoincrement)
            t.column(href)
            t.column(textLink)
            t.column(typeLink)
        })

        // Emails Table
        let emails = Table("emails")
        let emailID = Expression<Int64>("id")
        let idEmail = Expression<String>("id_email")
        let domain = Expression<String>("domain")
        try db.run(emails.create { t in
            t.column(emailID, primaryKey: .autoincrement)
            t.column(idEmail)
            t.column(domain)
        })

        // Persons Table
        let persons = Table("persons")
        let personID = Expression<Int64>("id")
        let namePerson = Expression<String?>("name")
        let emailReference = Expression<Int64?>("email_id")
        let linkReference = Expression<Int64?>("link_id")
        try db.run(persons.create { t in
            t.column(personID, primaryKey: .autoincrement)
            t.column(namePerson)
            t.column(emailReference)
            t.column(linkReference)
            t.foreignKey(emailReference, references: emails, emailID, delete: .setNull)
            t.foreignKey(linkReference, references: links, linkID, delete: .setNull)
        })

        // Points Table
        let points = Table("points")
        let pointID = Expression<Int64>("id")
        let latPoint = Expression<Double>("lat")
        let lonPoint = Expression<Double>("lon")
        let elePoint = Expression<Double?>("ele")
        let timePoint = Expression<Date?>("time")
        try db.run(points.create { t in
            t.column(pointID, primaryKey: .autoincrement)
            t.column(latPoint)
            t.column(lonPoint)
            t.column(elePoint)
            t.column(timePoint)
        })

        // PointSegments Table
        let pointsegments = Table("pointsegments")
        let pointsegmentID = Expression<Int64>("id")
        let pointReference = Expression<Int64>("point_id")
        try db.run(pointsegments.create { t in
            t.column(pointsegmentID, primaryKey: .autoincrement)
            t.column(pointReference)
            t.foreignKey(pointReference, references: points, pointID)
        })

        // Boundaries Table
        let boundaries = Table("boundaries")
        let boundaryID = Expression<Int64>("id")
        let minLat = Expression<Double>("minLat")
        let minLon = Expression<Double>("minLon")
        let maxLat = Expression<Double>("maxLat")
        let maxLon = Expression<Double>("maxLon")
        try db.run(boundaries.create { t in
            t.column(boundaryID, primaryKey: .autoincrement)
            t.column(minLat)
            t.column(minLon)
            t.column(maxLat)
            t.column(maxLon)
        })

    } catch {
        // Handle error
        print(error)
    }

}
