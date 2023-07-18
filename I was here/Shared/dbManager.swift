//
//  dbManager.swift
//  I was here
//
//  Created by Marco Carandente on 15.7.2023.
//

import Foundation
import SQLite
import CoreGPX
let dbQueue = DispatchQueue(label: "dbQueue", qos: .background)


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
        let version = Expression<String?>("version")
        let creator = Expression<String?>("creator")
        let importDate = Expression<Date>("importDate")
        let fileName = Expression<String?>("filename")
        let gpx_extensions = Expression<String?>("extensions")

        try db.run(gpx.create { t in
            t.column(gpxID, primaryKey: .autoincrement)
            t.column(version)
            t.column(creator)
            t.column(importDate)
            t.column(fileName)
            t.column(gpx_extensions)
        })

        // Metadata Table
        let metadata = Table("metadata")
        let metadataID = Expression<Int64>("id")
        let gpxReference = Expression<Int64>("gpx_id")
        let name = Expression<String?>("name")
        let desc = Expression<String?>("desc")
        let time = Expression<Date?>("time")
        let keywords = Expression<String?>("keywords")
        let metadata_extensions = Expression<String?>("extensions")
        
        try db.run(metadata.create { t in
            t.column(metadataID, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.column(name)
            t.column(desc)
            t.column(time)
            t.column(keywords)
            t.column(metadata_extensions)
            
            t.foreignKey(gpxReference, references: gpx, gpxID)

        })
        
        // Tracks Table
        let tracks = Table("tracks")
        let trackID = Expression<Int64>("id")
        let gpxRefTracks = Expression<Int64>("gpx_id")
        let nameTracks = Expression<String?>("name")
        let cmtTracks = Expression<String?>("cmt")
        let descTracks = Expression<String?>("desc")
        let srcTracks = Expression<String?>("src")
        let numberTracks = Expression<Int>("number")
        let typeTracks = Expression<String?>("type")
        let extensionsTracks = Expression<String?>("extensions")

        try db.run(tracks.create { t in
            t.column(trackID, primaryKey: .autoincrement)
            t.column(gpxRefTracks)
            t.column(nameTracks)
            t.column(cmtTracks)
            t.column(descTracks)
            t.column(srcTracks)
            t.column(numberTracks)
            t.column(typeTracks)
            t.column(extensionsTracks)
    
            t.foreignKey(gpxRefTracks, references: gpx, gpxID)

        })
        
        // TrackSegments Table
        let tracksegments = Table("tracksegments")
        let tracksegmentID = Expression<Int64>("id")
        let trackReference = Expression<Int64>("track_id")
        let gpxRefTrackSegments = Expression<Int64>("gpx_id")

        try db.run(tracksegments.create { t in
            t.column(tracksegmentID, primaryKey: .autoincrement)
            t.column(trackReference)
            t.column(gpxRefTrackSegments)

            t.foreignKey(trackReference, references: tracks, trackID)
            t.foreignKey(gpxRefTrackSegments, references: gpx, gpxID)
        })
        
        // Routes Table
        let routes = Table("routes")
        let routeID = Expression<Int64>("id")
        let gpxRefRoutes = Expression<Int64>("gpx_id")
        
        let nameRoutes = Expression<String?>("name")
        let cmtRoutes = Expression<String?>("cmt")
        let descRoutes = Expression<String?>("desc")
        let srcRoutes = Expression<String?>("src")
        let number = Expression<Int?>("number")
        let typeRoutes = Expression<String?>("type")
        let extensionsRoutes = Expression<String?>("extensions")

        try db.run(routes.create { t in
            t.column(routeID, primaryKey: .autoincrement)
            t.column(gpxRefRoutes)
            t.column(nameRoutes)
            t.column(cmtRoutes)
            t.column(descRoutes)
            t.column(srcRoutes)
            t.column(number)
            t.column(typeRoutes)
            t.column(extensionsRoutes)
            
            t.foreignKey(gpxRefRoutes, references: gpx, gpxID)

        })
        
        // Waypoints Table
        let waypoints = Table("waypoints")
        let waypointID = Expression<Int64>("id")
        let wptGpxReference = Expression<Int64>("gpx_id")
        let wptTrackSegmentReference = Expression<Int64?>("trkseg_id")
        let wptRouteReference = Expression<Int64?>("route_id")

        let ele = Expression<Double?>("ele")
        let waypointTime = Expression<Date?>("time")
        let lat = Expression<Double?>("lat")
        let lon = Expression<Double?>("lon")
        let magvar = Expression<Double?>("magvar")
        let geoidheight = Expression<Double?>("geoidheight")
        let wptName = Expression<String?>("name")
        let cmt = Expression<String?>("cmt")
        let wptDesc = Expression<String?>("desc")
        let src = Expression<String?>("src")
        let sym = Expression<String?>("sym")
        let type = Expression<String?>("type")
        let fix = Expression<String?>("fix")
        let sat = Expression<Int?>("sat")
        let hdop = Expression<Double?>("hdop")
        let vdop = Expression<Double?>("vdop")
        let pdop = Expression<Double?>("pdop")
        let ageofdgpsdata = Expression<Double?>("ageofdgpsdata")
        let dgpsid = Expression<Double?>("dgpsid")
        let wptExtensions = Expression<String?>("extensions")
        
        try db.run(waypoints.create { t in
            t.column(waypointID, primaryKey: .autoincrement)
            t.column(wptGpxReference)
            t.column(wptTrackSegmentReference)
            t.column(wptRouteReference)

            t.column(ele)
            t.column(waypointTime)
            t.column(lat)
            t.column(lon)
            t.column(magvar)
            t.column(geoidheight)
            t.column(wptName)
            t.column(cmt)
            t.column(wptDesc)
            t.column(src)
            t.column(sym)
            t.column(type)
            t.column(fix)
            t.column(sat)
            t.column(hdop)
            t.column(vdop)
            t.column(pdop)
            t.column(ageofdgpsdata)
            t.column(dgpsid)
            t.column(wptExtensions)
            
            t.foreignKey(wptGpxReference, references: gpx, gpxID)
            t.foreignKey(wptTrackSegmentReference, references: tracksegments, tracksegmentID)
            t.foreignKey(wptRouteReference, references: routes, routeID)

        })

        
        // Extensions Table
        let extensions = Table("extensions")
        let extensionID = Expression<Int64>("id")
        let gpxRefExtensions = Expression<Int64>("gpx_id")
        let raw = Expression<String?>("raw")
        try db.run(extensions.create { t in
            t.column(extensionID, primaryKey: .autoincrement)
            t.column(raw)
            t.column(gpxRefExtensions)
            
            t.foreignKey(gpxRefExtensions, references: gpx, gpxID)

        })

        // Copyright Table
        let copyright = Table("copyright")
        let gpxRefCopyright = Expression<Int64>("gpx_id")
        let metadataRefCopyright = Expression<Int64>("metadata_id")
        let copyrightID = Expression<Int64>("id")
        
        let authorCopyright = Expression<String?>("author")
        let year = Expression<Int?>("year")
        let license = Expression<String?>("license")
        
        try db.run(copyright.create { t in
            t.column(copyrightID, primaryKey: .autoincrement)
            t.column(authorCopyright)
            t.column(year)
            t.column(license)
            t.column(gpxRefCopyright)
            t.column(metadataRefCopyright)
            
            t.foreignKey(gpxRefCopyright, references: gpx, gpxID)
            t.foreignKey(metadataRefCopyright, references: metadata, metadataID)
        })

        // Persons Table
        let persons = Table("persons")
        let personID = Expression<Int64>("id")
        let gpxRefPersons = Expression<Int64>("gpx_id")
        let metadataRefPersons = Expression<Int64>("metadata_id")
     
        let namePerson = Expression<String?>("name")
        try db.run(persons.create { t in
            t.column(personID, primaryKey: .autoincrement)
            t.column(namePerson)
            t.column(gpxRefPersons)
            t.column(metadataRefPersons)
            t.foreignKey(gpxRefPersons, references: gpx, gpxID)
            t.foreignKey(metadataRefPersons, references: metadata, metadataID)
        })

        // Links Table
        let links = Table("links")
        let linkID = Expression<Int64>("id")
        let gpxRefLinks = Expression<Int64>("gpx_id")
        let metadataRef = Expression<Int64>("metadata_id")
        let waypointsRef = Expression<Int64>("waypoint_id")
        let href = Expression<String>("href")
        let textLink = Expression<String?>("text")
        let typeLink = Expression<String?>("type")
        
        try db.run(links.create { t in
            t.column(linkID, primaryKey: .autoincrement)
            t.column(href)
            t.column(textLink)
            t.column(typeLink)
            t.column(gpxRefLinks)
            t.column(metadataRef)
            t.column(waypointsRef)

            t.foreignKey(gpxRefLinks, references: gpx, gpxID)
            t.foreignKey(metadataRef, references: metadata, metadataID)
            t.foreignKey(waypointsRef, references: waypoints, waypointID)
        })
        
        // Emails Table
        let emails = Table("emails")
        let emailID = Expression<Int64>("id")
        let gpxRefEmails = Expression<Int64>("gpx_id")

        let idEmail = Expression<String?>("id_email")
        let domain = Expression<String?>("domain")

        try db.run(emails.create { t in
            t.column(emailID, primaryKey: .autoincrement)
            t.column(idEmail)
            t.column(domain)
            t.column(gpxRefEmails)
            
            t.foreignKey(gpxRefEmails, references: gpx, gpxID)
        })
        
        // PointSegments Table
        let pointsegments = Table("pointsegments")
        let pointsegmentID = Expression<Int64>("id")
        let gpxRefPointSegments = Expression<Int64>("gpx_id")

        try db.run(pointsegments.create { t in
            t.column(pointsegmentID, primaryKey: .autoincrement)
            t.column(gpxRefPointSegments)
            t.foreignKey(gpxRefPointSegments, references: gpx, gpxID)
        })
        
        // Points Table
        let points = Table("points")
        let pointID = Expression<Int64>("id")
        let latPoint = Expression<Double>("lat")
        let lonPoint = Expression<Double>("lon")
        let elePoint = Expression<Double?>("ele")
        let timePoint = Expression<Date?>("time")
        let gpxRefPoints = Expression<Int64>("gpx_id")
        let pointSegmentRef = Expression<Int64>("ptseg_id")

        try db.run(points.create { t in
            t.column(pointID, primaryKey: .autoincrement)
            t.column(latPoint)
            t.column(lonPoint)
            t.column(elePoint)
            t.column(timePoint)
            t.column(gpxRefPoints)
            t.column(pointSegmentRef)
            
            t.foreignKey(gpxRefPoints, references: gpx, gpxID)
            t.foreignKey(pointSegmentRef, references: pointsegments, pointsegmentID)

        })


        // Boundaries Table
        let boundaries = Table("boundaries")
        let boundaryID = Expression<Int64>("id")
        let minLat = Expression<Double?>("minLat")
        let minLon = Expression<Double?>("minLon")
        let maxLat = Expression<Double?>("maxLat")
        let maxLon = Expression<Double?>("maxLon")
        
        let gpxRefBoundaries = Expression<Int64>("gpx_id")
        let metadataRefBoundaries = Expression<Int64>("metadata_id")
        
        try db.run(boundaries.create { t in
            t.column(boundaryID, primaryKey: .autoincrement)
            t.column(minLat)
            t.column(minLon)
            t.column(maxLat)
            t.column(maxLon)
            t.column(gpxRefBoundaries)
            t.column(metadataRefBoundaries)
                       
            t.foreignKey(gpxRefBoundaries, references: gpx, gpxID)
            t.foreignKey(metadataRefBoundaries, references: metadata, metadataID)

        })

    } catch {
        // Handle error
        print(error)
    }
}

func populateFromGPX(gpx: GPXRoot, url: URL) {
    dbQueue.async {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let db = try Connection("\(path)/iwh.sqlite3")
            let jsonEncoder = JSONEncoder()

            //GPX table
            let gpxTable = Table("gpx")
            let gpxID = Expression<Int64>("id")
            let version = Expression<String?>("version")
            let creator = Expression<String?>("creator")
            let importDate = Expression<Date>("importDate")
            let fileName = Expression<String>("fileName")
            let extensions = Expression<String?>("extensions")
            print(gpx.version, gpx.creator)
            let date = Date()
            let importFilename = url.lastPathComponent
            
            //for now, extensions are put as raw data
            let jsonExtension = try jsonEncoder.encode(gpx.extensions)
            let jsonExtensionString = String(data: jsonExtension, encoding: .utf8)
            try db.transaction {
                let gpxID = try db.run(gpxTable.insert(version <- gpx.version, creator <- gpx.creator, importDate <- date, extensions <- jsonExtensionString, fileName <- importFilename))
            
            //Metadata table
            let metadataTable = Table("metadata")
            let metadataID = Expression<Int64>("id")
            let gpx_id = Expression<Int64>("gpx_id")
            let name = Expression<String?>("name")
            let desc = Expression<String?>("desc")
            let time = Expression<Date?>("time")
            let keywords = Expression<String?>("keywords")
            let extensions = Expression<String?>("extensions")
                
            if let metadata = gpx.metadata {
                let jsonExtension = try jsonEncoder.encode(metadata.extensions)
                let jsonExtensionString = String(data: jsonExtension, encoding: .utf8)
                
                let metadataInsert = metadataTable.insert(gpx_id <- gpxID, name <- metadata.name, desc <- metadata.desc, time <- metadata.time, keywords <- metadata.keywords, extensions <- jsonExtensionString)
                let metadataID = try db.run(metadataInsert)
                // Insert into boundaries
                if let boundary = metadata.bounds {
                    try populateBoundariesTable(db: db, boundary: boundary, gpxID: gpxID, metadataID: metadataID)
                }
            }

            }
        } catch {
            print("Database operation failed: \(error)")
        }
    }
}
func populateBoundariesTable(db: Connection, boundary: GPXBounds, gpxID: Int64, metadataID: Int64) throws {
    let boundariesTable = Table("boundaries")
    let boundaryID = Expression<Int64>("id")
    let gpx_id = Expression<Int64>("gpx_id")
    let metadata_id = Expression<Int64>("metadata_id")
    let minLat = Expression<Double?>("minLat")
    let minLon = Expression<Double?>("minLon")
    let maxLat = Expression<Double?>("maxLat")
    let maxLon = Expression<Double?>("maxLon")
    
    let boundaryInsert = boundariesTable.insert(
        gpx_id <- gpxID,
        metadata_id <- metadataID,
        minLat <- boundary.minLatitude,
        minLon <- boundary.minLongitude,
        maxLat <- boundary.maxLatitude,
        maxLon <- boundary.maxLongitude
    )
    _ = try db.run(boundaryInsert)
}
