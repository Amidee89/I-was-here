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

let id = Expression<Int64>("id")
let gpxReference = Expression<Int64>("gpx_id")
let gpxExtensions = Expression<String?>("extensions")
let metadataReference = Expression<Int64>("metadata_id")

let name = Expression<String?>("name")
let time = Expression<Date?>("time")
let cmt = Expression<String?>("cmt")
let desc = Expression<String?>("desc")
let src = Expression<String?>("src")
let number = Expression<Int>("number")
let type = Expression<String?>("type")

let ele = Expression<Double?>("ele")
let lat = Expression<Double?>("lat")
let lon = Expression<Double?>("lon")

func createDB(){
    do {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        let db = try Connection("\(path)/iwh.sqlite3")
        print(db.description)
        // GPX Table
        let gpx = Table("gpx")
        let version = Expression<String?>("version")
        let creator = Expression<String?>("creator")
        let importDate = Expression<Date>("importDate")
        let fileName = Expression<String?>("filename")

        try db.run(gpx.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(version)
            t.column(creator)
            t.column(importDate)
            t.column(fileName)
            t.column(gpxExtensions)
        })

        // Metadata Table
        let metadata = Table("metadata")
        let keywords = Expression<String?>("keywords")
        
        try db.run(metadata.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.column(name)
            t.column(desc)
            t.column(time)
            t.column(keywords)
            t.column(gpxExtensions)
            
            t.foreignKey(gpxReference, references: gpx, id)

        })
        
        // Tracks Table
        let tracks = Table("tracks")
        let extensionsTracks = Expression<String?>("extensions")

        try db.run(tracks.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.column(name)
            t.column(cmt)
            t.column(desc)
            t.column(src)
            t.column(number)
            t.column(type)
            t.column(gpxExtensions)
    
            t.foreignKey(gpxReference, references: gpx, id)

        })
        
        // TrackSegments Table
        let tracksegments = Table("tracksegments")
        let trackReference = Expression<Int64>("track_id")

        try db.run(tracksegments.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(trackReference)
            t.column(gpxReference)

            t.foreignKey(trackReference, references: tracks, id)
            t.foreignKey(gpxReference, references: gpx, id)
        })
        
        // Routes Table
        let routes = Table("routes")
        let routeID = Expression<Int64>("id")

        try db.run(routes.create { t in
            t.column(routeID, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.column(name)
            t.column(cmt)
            t.column(desc)
            t.column(src)
            t.column(number)
            t.column(type)
            t.column(gpxExtensions)
            
            t.foreignKey(gpxReference, references: gpx, id)

        })
        
        // Waypoints Table
        let waypoints = Table("waypoints")
        let wptTrackSegmentReference = Expression<Int64?>("trkseg_id")
        let wptRouteReference = Expression<Int64?>("route_id")

        let magvar = Expression<Double?>("magvar")
        let geoidheight = Expression<Double?>("geoidheight")
        let sym = Expression<String?>("sym")
        let fix = Expression<String?>("fix")
        let sat = Expression<Int?>("sat")
        let hdop = Expression<Double?>("hdop")
        let vdop = Expression<Double?>("vdop")
        let pdop = Expression<Double?>("pdop")
        let ageofdgpsdata = Expression<Double?>("ageofdgpsdata")
        let dgpsid = Expression<Double?>("dgpsid")
        
        try db.run(waypoints.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.column(wptTrackSegmentReference)
            t.column(wptRouteReference)

            t.column(ele)
            t.column(time)
            t.column(lat)
            t.column(lon)
            t.column(magvar)
            t.column(geoidheight)
            t.column(name)
            t.column(cmt)
            t.column(desc)
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
            t.column(gpxExtensions)
            
            t.foreignKey(gpxReference, references: gpx, id)
            t.foreignKey(wptTrackSegmentReference, references: tracksegments, id)
            t.foreignKey(wptRouteReference, references: routes, id)

        })

        
        // Extensions Table
        let extensions = Table("extensions")
        let raw = Expression<String?>("raw")
        try db.run(extensions.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(raw)
            t.column(gpxReference)
            
            t.foreignKey(gpxReference, references: gpx, id)

        })

        // Copyright Table
        let copyright = Table("copyright")
        
        let authorCopyright = Expression<String?>("author")
        let year = Expression<Int?>("year")
        let license = Expression<String?>("license")
        
        try db.run(copyright.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(authorCopyright)
            t.column(year)
            t.column(license)
            t.column(gpxReference)
            t.column(metadataReference)
            
            t.foreignKey(gpxReference, references: gpx, id)
            t.foreignKey(metadataReference, references: metadata, id)
        })

        // Persons Table
        let persons = Table("persons")
     
        try db.run(persons.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(name)
            t.column(gpxReference)
            t.column(metadataReference)
            
            t.foreignKey(gpxReference, references: gpx, id)
            t.foreignKey(metadataReference, references: metadata, id)
        })

        // Links Table
        let links = Table("links")
        let waypointsReference = Expression<Int64>("waypoint_id")
        let href = Expression<String>("href")
        let textLink = Expression<String?>("text")
        let typeLink = Expression<String?>("type")
        
        try db.run(links.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(href)
            t.column(textLink)
            t.column(typeLink)
            t.column(gpxReference)
            t.column(metadataReference)
            t.column(waypointsReference)

            t.foreignKey(gpxReference, references: gpx, id)
            t.foreignKey(metadataReference, references: metadata, id)
            t.foreignKey(waypointsReference, references: waypoints, id)
        })
        
        // Emails Table
        let emails = Table("emails")
        let idEmail = Expression<String?>("id_email")
        let domain = Expression<String?>("domain")

        try db.run(emails.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(idEmail)
            t.column(domain)
            t.column(gpxReference)
            
            t.foreignKey(gpxReference, references: gpx, id)
        })
        
        // PointSegments Table
        let pointsegments = Table("pointsegments")

        try db.run(pointsegments.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.foreignKey(gpxReference, references: gpx, id)
        })
        
        // Points Table
        let points = Table("points")
        let pointSegmentReference = Expression<Int64>("ptseg_id")

        try db.run(points.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(lat)
            t.column(lon)
            t.column(ele)
            t.column(time)
            t.column(gpxReference)
            t.column(pointSegmentReference)
            
            t.foreignKey(gpxReference, references: gpx, id)
            t.foreignKey(pointSegmentReference, references: pointsegments, id)

        })


        // Boundaries Table
        let boundaries = Table("boundaries")
        let minLat = Expression<Double?>("minLat")
        let minLon = Expression<Double?>("minLon")
        let maxLat = Expression<Double?>("maxLat")
        let maxLon = Expression<Double?>("maxLon")
        
        try db.run(boundaries.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(minLat)
            t.column(minLon)
            t.column(maxLat)
            t.column(maxLon)
            t.column(gpxReference)
            t.column(metadataReference)
                       
            t.foreignKey(gpxReference, references: gpx, id)
            t.foreignKey(metadataReference, references: metadata, id)

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
            let id = Expression<Int64>("id")
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
                let id = try db.run(gpxTable.insert(version <- gpx.version, creator <- gpx.creator, importDate <- date, extensions <- jsonExtensionString, fileName <- importFilename))
            
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
                
                let metadataInsert = metadataTable.insert(gpx_id <- id, name <- metadata.name, desc <- metadata.desc, time <- metadata.time, keywords <- metadata.keywords, extensions <- jsonExtensionString)
                let metadataID = try db.run(metadataInsert)
                // Insert into boundaries
                if let boundary = metadata.bounds {
                    try populateBoundariesTable(db: db, boundary: boundary, id: id, metadataID: metadataID)
                }
                if let copyright = metadata.copyright{
                    try populateCopyrightTable (db: db, copyright: copyright, id: id, metadataID: metadataID)
                }
            }

            }
        } catch {
            print("Database operation failed: \(error)")
        }
    }
}
func populateBoundariesTable(db: Connection, boundary: GPXBounds, id: Int64, metadataID: Int64) throws {
    let boundariesTable = Table("boundaries")
    let minLat = Expression<Double?>("minLat")
    let minLon = Expression<Double?>("minLon")
    let maxLat = Expression<Double?>("maxLat")
    let maxLon = Expression<Double?>("maxLon")
    
    let boundaryInsert = boundariesTable.insert(
        gpxReference <- id,
        metadataReference <- metadataID,
        minLat <- boundary.minLatitude,
        minLon <- boundary.minLongitude,
        maxLat <- boundary.maxLatitude,
        maxLon <- boundary.maxLongitude
    )
    _ = try db.run(boundaryInsert)
}

func populateCopyrightTable(db: Connection, copyright: GPXCopyright, id: Int64, metadataID: Int64) throws {
    // Copyright Table
    let copyrightTable = Table("copyright")
    let authorCopyright = Expression<String?>("author")
    let year = Expression<Int?>("year")
    let license = Expression<String?>("license")
    
    //gpxCORE returns date instead of int (as it should be for spec)
    let calendar = Calendar.current
    let dateComponents = copyright.year.map { calendar.dateComponents([.year], from: $0) }
    let copyrightYear = dateComponents?.year
    
    let copyrightInsert = copyrightTable.insert(
        gpxReference <- id,
        metadataReference <- metadataID,
        authorCopyright <- copyright.author,
        year <- copyrightYear,
        license <- copyright.license
    )
    _ = try db.run(copyrightInsert)
}


