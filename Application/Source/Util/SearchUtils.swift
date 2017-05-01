//
//  SearchUtils.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 08/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

struct SearchUtils {
    static func searchTrips(trips: [Trip], query: String) -> [Trip] {
        let lowercaseQuery = query.lowercased()
        return trips.map { trip -> (relevance: Int, trip: Trip) in
            var relevance: Int = 0
            if let destination = trip.destination,
                destination.fullAddress.lowercased().contains(lowercaseQuery) {
                relevance += 1
            }
            if trip.comment.lowercased().contains(lowercaseQuery) {
                relevance += 1
            }
            return (relevance, trip)
            }
            .filter { $0.relevance > 0 }
            .sorted { $0.relevance > $1.relevance }
            .map { $0.trip }
    }
}
