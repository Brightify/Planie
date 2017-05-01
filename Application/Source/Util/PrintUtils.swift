//
//  PrintUtils.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 08/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

struct PrintUtils {
    typealias IntervalWithTrips = (interval: PrintableInterval, trips: [Trip])

    static func printableIntervals(trips: [Trip]) -> [IntervalWithTrips] {
        return PrintableInterval.allValues.map {
            (interval: $0, trips: trips.filter($0.includeTrip))
            }.filter { $0.trips.isNotEmpty }
    }

    static func printableHtml(interval: PrintableInterval, trips: [Trip]) -> String {
        let header = "<h1>\(L10n.Trip.Print.title)</h1>"

        // Mapping code was moved to this function to lower extremely long compilation time when used as closure.
        func formatTrip(trip: Trip) -> String {
            let parts: [String] = [
                "<p>",
                "<strong>\(L10n.Trip.destination): </strong>",
                "\(trip.destination?.fullAddress ?? "---")",
                "<br />",
                "<strong>\(L10n.Trip.begin): </strong>",
                "\(trip.begin?.string(dateStyle: .medium) ?? "---")",
                "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                "<strong>\(L10n.Trip.end): </strong>",
                "\(trip.end?.string(dateStyle: .medium) ?? "---")",
                "<br />",
                "<strong>\(L10n.Trip.comment): </strong>",
                "\(trip.comment.replacingOccurrences(of: "\n", with: "<br />"))",
                "</p>"]
            return parts.joined(separator: "")
        }

        return header + trips.map(formatTrip).joined(separator: "<hr>")
    }
}
