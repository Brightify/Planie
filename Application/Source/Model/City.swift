//
//  City.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import DataMapper
import Reactant

struct City: Deserializable, Serializable {
    var longitude: Double
    var latitude: Double
    var name: String
    var country: String?
    var region: String?
    var boundingBox: BoundingBox?

    init(_ data: DeserializableData) throws {
        longitude = data["lng"].get(or: 0)
        latitude =  data["lat"].get(or: 0)
        name = try data["name"].get()
        country = data["countryName"].get()
        region = data["adminName1"].get()
        boundingBox = data["bbox"].get()
    }

    func serialize(to data: inout SerializableData) {
        data["lng"].set(longitude)
        data["lat"].set(latitude)
        data["name"].set(name)
        data["countryName"].set(country)
        data["adminName1"].set(region)
        data["bbox"].set(boundingBox)
    }
}

extension City {
    init(longitude: Double,
         latitude: Double,
         name: String,
         country: String?,
         region: String?,
         boundingBox: BoundingBox?) {

        self.longitude = longitude
        self.latitude = latitude
        self.name = name
        self.country = country
        self.region = region
        self.boundingBox = boundingBox
    }

    var fullAddress: String {
        return [name, region, country].flatMap { $0 }.filter { $0.isNotEmpty }.joined(separator: ", ")
    }
}
