//
//  GeoNamesSearchBox.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import DataMapper

struct GeoNamesSearchBox: Deserializable {
    let cities: [City]

    init(_ data: DeserializableData) throws {
        cities = data["geonames"].get(or: [])
    }
}
