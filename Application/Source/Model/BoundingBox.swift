//
//  BoundingBox.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import DataMapper
import MapKit
import Reactant

struct BoundingBox: Mappable {
    var east: Double = 0
    var south: Double = 0
    var north: Double = 0
    var west: Double = 0

    init(_ data: DeserializableData) throws {
        try mapping(data)
    }

    mutating func mapping(_ data: inout MappableData) throws {
        data["east"].map(&east, or: 0)
        data["south"].map(&south, or: 0)
        data["north"].map(&north, or: 0)
        data["west"].map(&west, or: 0)
    }
}

extension BoundingBox {
    var mapRegion: MKCoordinateRegion {
        let topLeft = CLLocationCoordinate2D(latitude: north, longitude: west)
        let bottomRight = CLLocationCoordinate2D(latitude: south, longitude: east)
        let coordinates = [topLeft, bottomRight]
        return MKCoordinateRegion(center: coordinates.centerCoordinate(), span: coordinates.coordinateSpan())
    }
}

extension BoundingBox {
    init(east: Double, south: Double, north: Double, west: Double) {
        self.east = east
        self.south = south
        self.north = north
        self.west = west
    }
}
