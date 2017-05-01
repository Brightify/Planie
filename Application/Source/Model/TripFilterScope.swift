//
//  TripFilterScope.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 08/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import SwiftDate

enum TripFilterScope {
    case all
    case past
    case present
    case future

    static var allScopes: [TripFilterScope] = [.all, .past, .present, .future]

    var localizedDescription: String {
        switch self {
        case .all:
            return L10n.Trip.List.Filter.Scope.all
        case .past:
            return L10n.Trip.List.Filter.Scope.past
        case .present:
            return L10n.Trip.List.Filter.Scope.present
        case .future:
            return L10n.Trip.List.Filter.Scope.future
        }
    }

    func includeTrip(trip: Trip) -> Bool {
        switch self {
        case .all:
            return true
        case .past:
            guard let tripEnd = trip.end else { return false }
            return tripEnd < Date()
        case .present:
            guard let tripBegin = trip.begin, let tripEnd = trip.end else { return false }
            return tripBegin < Date() && tripEnd > Date()
        case .future:
            guard let tripBegin = trip.begin else { return false }
            return tripBegin > Date()
        }
    }
}
