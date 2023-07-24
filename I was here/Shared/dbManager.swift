//
//  dbManager.swift
//  I was here
//
//  Created by Marco Carandente on 15.7.2023.
//

import Foundation
import SQLite
import CoreGPX
import MapKit

var dbQueue = DispatchQueue(label: "iamhere.dbQueue", qos: .userInitiated)
let path = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
).first!
let dbFilePath = "\(path)/iwh.sqlite3"
var db : Connection? = nil

//Tables
let gpxTable = Table("gpx")
let metadataTable = Table("metadata")
let waypointsTable = Table("waypoints")
let copyrightTable = Table("copyright")
let linksTable = Table("links")
let routesTable = Table("routes")
let tracksegmentsTable = Table("tracksegments")
let tracksTable = Table("tracks")
let boundariesTable = Table("boundaries")
let personsTable = Table("persons")
let emailsTable = Table("emails")
let pointsegments = Table("pointsegments")
let pointsTable = Table("points")

//basic columns
let idColumn = Expression<Int64>("id")
let gpxReference = Expression<Int64>("gpx_id")
let gpxExtensionsColumn = Expression<String?>("extensions")

//references
let metadataReference = Expression<Int64?>("metadata_id")
let personReference = Expression<Int64?>("person_id")
let trackReference = Expression<Int64?>("track_id")
let trackSegmentReference = Expression<Int64?>("trkseg_id")
let routeReference = Expression<Int64?>("route_id")
let waypointsReference = Expression<Int64?>("waypoint_id")
let pointSegmentReference = Expression<Int64>("ptseg_id")


//gpx type
let importDate = Expression<Date>("importDate")
let fileName = Expression<String?>("filename")
let version = Expression<String?>("version")
let creator = Expression<String?>("creator")

//links type
let href = Expression<String?>("href")
let text = Expression<String?>("text")
let type = Expression<String?>("type")

//emails type
let idEmail = Expression<String?>("id_email")
let domain = Expression<String?>("domain")

//metadata type
let keywords = Expression<String?>("keywords")
let name = Expression<String?>("name")
let time = Expression<Date?>("time")
let cmt = Expression<String?>("cmt")
let desc = Expression<String?>("desc")
let src = Expression<String?>("src")
let number = Expression<Int?>("number")

//copyright type
let author = Expression<String?>("author")
let year = Expression<Int?>("year")
let license = Expression<String?>("license")

//waypoint type
let ele = Expression<Double?>("ele")
let lat = Expression<Double?>("lat")
let lon = Expression<Double?>("lon")
let magvar = Expression<Double?>("magvar")
let geoidheight = Expression<Double?>("geoidheight")
let sym = Expression<String?>("sym")
let fix = Expression<String?>("fix")
let sat = Expression<Int?>("sat")
let hdop = Expression<Double?>("hdop")
let vdop = Expression<Double?>("vdop")
let pdop = Expression<Double?>("pdop")
let ageofdgpsdata = Expression<Double?>("ageofdgpsdata")
let dgpsid = Expression<Int?>("dgpsid")

//bounds type
let minLat = Expression<Double?>("minLat")
let minLon = Expression<Double?>("minLon")
let maxLat = Expression<Double?>("maxLat")
let maxLon = Expression<Double?>("maxLon")

func createDB(){
    do {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        let db = try Connection("\(path)/iwh.sqlite3")
        print("creating: ", db.description)
        // GPX Table
        try db.run(gpxTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(version)
            t.column(creator)
            t.column(importDate)
            t.column(fileName)
            t.column(gpxExtensionsColumn)
        })

        // Metadata Table
        try db.run(metadataTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.column(name)
            t.column(desc)
            t.column(time)
            t.column(keywords)
            t.column(gpxExtensionsColumn)
            
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
        })
        
        // Tracks Table
        try db.run(tracksTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.column(name)
            t.column(cmt)
            t.column(desc)
            t.column(src)
            t.column(number)
            t.column(type)
            t.column(gpxExtensionsColumn)
    
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
        })
        
        // TrackSegments Table
        try db.run(tracksegmentsTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(trackReference)
            t.column(gpxReference)
            t.column(gpxExtensionsColumn)

            t.foreignKey(trackReference, references: tracksTable, idColumn)
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
        })
        
        // Routes Table
        try db.run(routesTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.column(name)
            t.column(cmt)
            t.column(desc)
            t.column(src)
            t.column(number)
            t.column(type)
            t.column(gpxExtensionsColumn)
            
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
        })
        
        // Waypoints Table
        try db.run(waypointsTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.column(trackSegmentReference)
            t.column(routeReference)

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
            t.column(gpxExtensionsColumn)
            
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
            t.foreignKey(trackSegmentReference, references: tracksegmentsTable, idColumn)
            t.foreignKey(routeReference, references: routesTable, idColumn)
        })

        // Copyright Table
        try db.run(copyrightTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(author)
            t.column(year)
            t.column(license)
            t.column(gpxReference)
            t.column(metadataReference)
            
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
            t.foreignKey(metadataReference, references: metadataTable, idColumn)
        })

        // Persons Table
        try db.run(personsTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(name)
            t.column(gpxReference)
            t.column(metadataReference)
            
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
            t.foreignKey(metadataReference, references: metadataTable, idColumn)
        })

        // Links Table

        try db.run(linksTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(href)
            t.column(text)
            t.column(type)
            t.column(gpxReference)
            t.column(metadataReference)
            t.column(waypointsReference)
            t.column(personReference)
            t.column(trackReference)
            t.column(routeReference)

            t.foreignKey(gpxReference, references: gpxTable, idColumn)
            t.foreignKey(metadataReference, references: metadataTable, idColumn)
            t.foreignKey(waypointsReference, references: waypointsTable, idColumn)
            t.foreignKey(personReference, references: personsTable, idColumn)
            t.foreignKey(trackReference, references: tracksTable, idColumn)
            t.foreignKey(routeReference, references: routesTable, idColumn)
            

        })
        
        // Emails Table
        try db.run(emailsTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(idEmail)
            t.column(domain)
            t.column(gpxReference)
            t.column(personReference)
            
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
            t.foreignKey(personReference, references: personsTable, idColumn)
            
        })
        
        // PointSegments Table
        try db.run(pointsegments.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(gpxReference)
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
        })
        
        // Points Table
        try db.run(pointsTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(lat)
            t.column(lon)
            t.column(ele)
            t.column(time)
            t.column(gpxReference)
            t.column(pointSegmentReference)
            
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
            t.foreignKey(pointSegmentReference, references: pointsegments, idColumn)
        })

        // Boundaries Table
        try db.run(boundariesTable.create { t in
            t.column(idColumn, primaryKey: .autoincrement)
            t.column(minLat)
            t.column(minLon)
            t.column(maxLat)
            t.column(maxLon)
            t.column(gpxReference)
            t.column(metadataReference)
                       
            t.foreignKey(gpxReference, references: gpxTable, idColumn)
            t.foreignKey(metadataReference, references: metadataTable, idColumn)
        })

    } catch {
        // Handle error
        print(error)
    }
}


func setupDatabase(){
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: dbFilePath) {
        createDB()
    }
    
    do {
        db = try Connection(dbFilePath)
    } catch {
        print("Unable to open database")
    }
    if db != nil {
        db!.busyTimeout = 5 // error after 5 seconds (does multiple retries)

        db!.busyHandler({ tries in
            tries < 10  // error after 30 tries
        })
    }


}

func processGPXFile(at url: URL) {
    var fileSizeCalculation : NSNumber? = nil
    do {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        if let fileSize = fileAttributes[FileAttributeKey.size] as? NSNumber {
            print("File size: \(fileSize.intValue) bytes")
            fileSizeCalculation = fileSize
        }
    } catch {
        print("Failed to get file size for \(url.path)")
    }

    if let gpx = GPXParser(withURL: url)?.parsedData() {
            populateFromGPX(gpx: gpx, url: url, fileSize: fileSizeCalculation!)
    }
}


func populateFromGPX(gpx: GPXRoot, url: URL, fileSize: NSNumber) {
    setupDatabase()
    dbQueue.async {
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let importFilename = url.lastPathComponent
            print("started importing: ", importFilename)
            let db = try Connection("\(path)/iwh.sqlite3")
            //GPX table
            var id: Int64? = nil
            let date = Date()
            
            var jsonExtensionString: String? = nil
            if let extensions = gpx.extensions {
                let jsonEncoder = JSONEncoder()
                let jsonExtension = try jsonEncoder.encode(extensions)
                jsonExtensionString = String(data: jsonExtension, encoding: .utf8)
            }
            print("gpx insert run for \(importFilename)")
            var done = false
            while !done
            {
                do{
                    try db.transaction
                    {
                        id = try db.run(gpxTable.insert(version <- gpx.version, creator <- gpx.creator, importDate <- date, fileName <- importFilename, gpxExtensionsColumn <- jsonExtensionString))
                        done = true
                    }

                }catch{
                    print("Retrying gpx \(importFilename): \(error)")
                    Thread.sleep(forTimeInterval: 1) // wait for 1 seconds
                }
            }
            print("gpx insert run for \(importFilename) done")
            
            if let receivedId = id
            {
                print("metadata start for \(importFilename)")
                if let metadata = gpx.metadata {
                        try populateMetadataTable (db:db, metadata: metadata, gpxID: receivedId)
                    }
                print("metadata done for \(importFilename)")
                print("tracks start for \(importFilename)")
                let tracks = gpx.tracks
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.concurrentPerform(iterations: tracks.count) { index in
                        var done = false
                        while !done {
                            do {
                                try populateTracksTable(db: db, track: tracks[index], gpxID: receivedId)
                                done = true
                                break
                                
                            } catch {
                                print("Retrying track \(index): \(error)")
                                Thread.sleep(forTimeInterval: 1) // wait for 1 seconds
                            }
                        }
                    }
                }
                print("tracks done for \(importFilename)")
                print("routes start for \(importFilename)")
                
                for route in gpx.routes{
                    var done = false
                    while !done {
                        do{
                            try populateRoutesTable (db:db, route: route, gpxID: receivedId)
                            done = true
                            break
                        } catch {
                            print("Retrying route: \(error)")
                        }
                    }
                }
                print("routes done for \(importFilename)")
                print("waypoints start for \(importFilename)")
                var done = false
                while !done {
                    do{
                        try populateWaypointsTable(db: db, waypoints: gpx.waypoints, gpxID: receivedId)
                        done = true
                        break
                    } catch {
                        print("Retrying route waypoint: \(error)")
                    }
                }
                print("waypoints end for \(importFilename)")

                let endTime = CFAbsoluteTimeGetCurrent()
                let executionTime = (endTime - startTime) * 1000
                print("finished importing: ", importFilename, "took ", executionTime, "ms")
                print("ms per byte: ", (executionTime/Double(fileSize)) )
            }
            
        } catch {
            print("Database operation failed: \(error)")
        }
        Thread.sleep(forTimeInterval: 2) // wait for 5 seconds
    }

}

func populateTracksTable (db: Connection, track: GPXTrack, gpxID: Int64) throws{
    let jsonEncoder = JSONEncoder()
    let jsonExtension = try jsonEncoder.encode(track.extensions)
    let jsonExtensionString = String(data: jsonExtension, encoding: .utf8)
    let tracksInsert = tracksTable.insert(gpxReference <- gpxID,
                                          name <- track.name,
                                          cmt <- track.comment,
                                          desc <- track.desc,
                                          src <- track.source,
                                          number <- track.number,
                                          type <- track.type,
                                          gpxExtensionsColumn <- jsonExtensionString)
    //print("tracks insert")
    let id = try db.run(tracksInsert)
    for link in track.links{
        try populateLinkTable(db: db, link: link, gpxID: gpxID, trackID: id)
    }
    for tracksegment in track.segments
    {
        try populateTrackSegmentsTable(db: db, segment: tracksegment, gpxID: gpxID, trackID: id)
    }
}

func populateTrackSegmentsTable (db: Connection, segment: GPXTrackSegment, gpxID: Int64, trackID: Int64) throws
{
    let jsonEncoder = JSONEncoder()
    let jsonExtension = try jsonEncoder.encode(segment.extensions)
    let jsonExtensionString = String(data: jsonExtension, encoding: .utf8)
    let trackSegmentInsert = tracksegmentsTable.insert(gpxReference <- gpxID,
                                          trackReference <- trackID,
                                          gpxExtensionsColumn <- jsonExtensionString)
    //print("track segment insert")
    let id = try db.run(trackSegmentInsert)
    try populateWaypointsTable(db: db, waypoints: segment.points, gpxID: gpxID, tracksegmentID: id)
}

func populateRoutesTable (db: Connection, route: GPXRoute, gpxID: Int64) throws{
    let jsonEncoder = JSONEncoder()
    let jsonExtension = try jsonEncoder.encode(route.extensions)
    let jsonExtensionString = String(data: jsonExtension, encoding: .utf8)
    let routesInsert = routesTable.insert(gpxReference <- gpxID,
                                          name <- route.name,
                                          cmt <- route.comment,
                                          desc <- route.desc,
                                          src <- route.source,
                                          number <- route.number,
                                          type <- route.type,
                                          gpxExtensionsColumn <- jsonExtensionString)
    //print("routes insert")
    let id = try db.run(routesInsert)
    for link in route.links{
        try populateLinkTable(db: db, link: link, gpxID: gpxID, routeID: id)
    }
    try populateWaypointsTable(db: db, waypoints: route.points, gpxID: gpxID, routeID: id)

}


func populateWaypointsTable(db: Connection, waypoints: [GPXWaypoint], gpxID: Int64, tracksegmentID: Int64? = nil, routeID: Int64? = nil) throws {
    if waypoints.isEmpty{
        return
    }
    try db.transaction {
        var rows: [[Setter]] = []
               for waypoint in waypoints {
                   let jsonEncoder = JSONEncoder()
                   let jsonExtension = try jsonEncoder.encode(waypoint.extensions)
                   let jsonExtensionString = String(data: jsonExtension, encoding: .utf8)
                   let setters: [Setter] = [
                       gpxReference <- gpxID,
                       trackSegmentReference <- tracksegmentID,
                       routeReference <- routeID,
                       ele <- waypoint.elevation,
                       time <- waypoint.time,
                       lat <- waypoint.latitude,
                       lon <- waypoint.longitude,
                       magvar <- waypoint.magneticVariation,
                       geoidheight <- waypoint.geoidHeight,
                       name <- waypoint.name,
                       cmt <- waypoint.comment,
                       desc <- waypoint.desc,
                       src <- waypoint.source,
                       sym <- waypoint.symbol,
                       type <- waypoint.type,
                       fix <- waypoint.fix?.rawValue,
                       sat <- waypoint.satellites,
                       hdop <- waypoint.horizontalDilution,
                       vdop <- waypoint.verticalDilution,
                       pdop <- waypoint.positionDilution,
                       ageofdgpsdata <- waypoint.ageofDGPSData,
                       dgpsid <- waypoint.DGPSid,
                       gpxExtensionsColumn <- jsonExtensionString
                   ]
                   rows.append(setters)
               }
               // print("waypoint insert")
               _ = try db.run(waypointsTable.insertMany(rows))
        }
}

func populateMetadataTable (db: Connection, metadata: GPXMetadata, gpxID: Int64) throws{
    //Metadata table
    let jsonEncoder = JSONEncoder()
    let jsonExtension = try jsonEncoder.encode(metadata.extensions)
    let jsonExtensionString = String(data: jsonExtension, encoding: .utf8)
    
    let metadataInsert = metadataTable.insert(gpxReference <- gpxID,
                                              name <- metadata.name,
                                              desc <- metadata.desc,
                                              time <- metadata.time,
                                              keywords <- metadata.keywords,
                                              gpxExtensionsColumn <- jsonExtensionString)
    let id = try db.run(metadataInsert)
    
    //linked tables
    if let boundary = metadata.bounds {
        try populateBoundariesTable(db: db, boundary: boundary, gpxID: gpxID, metadataID: id)
    }
    if let copyright = metadata.copyright{
        try populateCopyrightTable (db: db, copyright: copyright, gpxID: gpxID, metadataID: id)
    }
    if let person = metadata.author{
        try populatePersonsTable(db: db, person: person, gpxID: gpxID, metadataID: id)
    }
    for link in metadata.links{
        try populateLinkTable(db: db, link: link, gpxID: gpxID, metadataID: id)
    }
}

func populateBoundariesTable(db: Connection, boundary: GPXBounds, gpxID: Int64, metadataID: Int64) throws {
    
    let boundaryInsert = boundariesTable.insert(
        gpxReference <- gpxID,
        metadataReference <- metadataID,
        minLat <- boundary.minLatitude,
        minLon <- boundary.minLongitude,
        maxLat <- boundary.maxLatitude,
        maxLon <- boundary.maxLongitude
    )
    //print("bounds insert")

    _ = try db.run(boundaryInsert)
}

func populateCopyrightTable(db: Connection, copyright: GPXCopyright, gpxID: Int64, metadataID: Int64) throws {
    // Copyright Table
    //gpxCORE returns date instead of int (as it should be for spec)
    let calendar = Calendar.current
    let dateComponents = copyright.year.map { calendar.dateComponents([.year], from: $0) }
    let copyrightYear = dateComponents?.year
    //print("copyright insert")

    let copyrightInsert = copyrightTable.insert(
        gpxReference <- gpxID,
        metadataReference <- metadataID,
        author <- copyright.author,
        year <- copyrightYear,
        license <- copyright.license
    )
    _ = try db.run(copyrightInsert)
}

func populatePersonsTable(db: Connection, person: GPXPerson, gpxID: Int64, metadataID: Int64? = nil) throws {
    
    let personInsert = personsTable.insert(
        gpxReference <- gpxID,
        name <- person.name,
        metadataReference <- metadataID
    )
    //print("person insert")

    let personID = try db.run(personInsert)
    
    if let link = person.link{
        try populateLinkTable(db: db, link: link, gpxID: gpxID, personID: personID)
    }
    if let email = person.email{
        try populateEmailTable(db: db, email: email, gpxID: gpxID, personID: personID)
    }
    
}

func populateLinkTable(db: Connection, link: GPXLink, gpxID: Int64, metadataID: Int64? = nil, waypointID: Int64? = nil, trackID: Int64? = nil, personID: Int64? = nil, routeID: Int64? = nil)throws {
    //print("link insert")

    let linksInsert = linksTable.insert(
        gpxReference <- gpxID,
        href <- link.href,
        text <- link.text,
        type <- link.mimetype,
        metadataReference <- metadataID,
        trackReference <- trackID,
        personReference <- personID,
        routeReference <- routeID
    )
     _ = try db.run(linksInsert)
}

func populateEmailTable(db: Connection, email: GPXEmail, gpxID: Int64, personID:Int64) throws {
    print("email insert")

    let insert = emailsTable.insert(
        gpxReference <- gpxID,
        personReference <- personID,
        idEmail <- email.emailID,
        domain <- email.domain
    )
    _ = try db.run(insert)
}

func loadWaypointsFromDatabase(number:Int = 100) -> (waypoints: [MKPointAnnotation], boundingRegion: MKCoordinateRegion) {
    if db == nil {
        setupDatabase()
    }
    var minLat = Double.greatestFiniteMagnitude
    var maxLat = -Double.greatestFiniteMagnitude
    var minLon = Double.greatestFiniteMagnitude
    var maxLon = -Double.greatestFiniteMagnitude
    
    var annotations: [MKPointAnnotation] = []
    do {
        let query = waypointsTable.filter(trackSegmentReference == nil && routeReference == nil).order(time.desc).limit(number)
        for waypoint in try db!.prepare(query) {
            let annotation = MKPointAnnotation()
            if (waypoint[lat] != nil) && (waypoint[lon] != nil) {
                annotation.coordinate = CLLocationCoordinate2D(latitude: waypoint[lat]!, longitude: waypoint[lon]!)
                annotations.append(annotation)
                minLat = min(minLat, waypoint[lat]!)
                maxLat = max(maxLat, waypoint[lat]!)
                minLon = min(minLon, waypoint[lon]!)
                maxLon = max(maxLon, waypoint[lon]!)
            }
        }
    } catch {
        // Handle failure to read from the database here
    }
    let centerLat = (minLat + maxLat) / 2
    let centerLon = (minLon + maxLon) / 2
    let spanLat = abs(maxLat - minLat)
    let spanLon = abs(maxLon - minLon)
    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon), span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon))

    return (annotations, region)
}
