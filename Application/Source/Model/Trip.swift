//
//  Trip.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import DataMapper
import SwiftDate
import Reactant

struct Trip: FirebaseEntity {
    var id: String?
    var destination: City?
    var begin: Date?
    var end: Date?
    var comment: String = ""
}

extension Trip: Deserializable, Serializable {

    init(_ data: DeserializableData) {
        id = data["id"].get()
        destination = data["destination"].get()
        begin = data["begin"].get(using: ISO8601DateTransformation())
        end = data["end"].get(using: ISO8601DateTransformation())
        comment = data["comment"].get() ?? ""
    }

    func serialize(to data: inout SerializableData) {
        data["id"].set(id)
        data["destination"].set(destination)
        data["begin"].set(begin, using: ISO8601DateTransformation())
        data["end"].set(end, using: ISO8601DateTransformation())
        data["comment"].set(comment)
    }    
}

extension Trip {
    var dateRangeWithCountdown: String {
        let dateRange = [begin?.string(dateStyle: .medium, timeStyle: .none, in: nil),
                         end?.string(dateStyle: .medium, timeStyle: .none, in: nil)]
            .compactMap { $0 }
            .joined(separator: " - ")
        let countdown: String
        if let begin = begin, Date().isBefore(date: begin, granularity: .day) {
            let naturalString = begin.colloquial(to: Date())

            countdown = " (\(L10n.Trip.List.countdown(naturalString!)))"
        } else {
            countdown = ""
        }
        return dateRange + countdown
    }
}
