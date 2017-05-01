//
//  PrintableInterval.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 08/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import SwiftDate

enum PrintableInterval {
    case next30Days
    case nextMonth
    case restOfThisYear
    case allFutureTrips
    case everything
}

extension PrintableInterval {
    static var allValues: [PrintableInterval] = [.next30Days, .nextMonth, .restOfThisYear, .allFutureTrips, .everything]

    var localizedDescription: String {
        switch self {
        case .next30Days:
            return L10n.Trip.Print.next30Days
        case .nextMonth:
            return L10n.Trip.Print.nextMonth
        case .restOfThisYear:
            return L10n.Trip.Print.restOfThisYear
        case .allFutureTrips:
            return L10n.Trip.Print.allFutureTrips
        case .everything:
            return L10n.Trip.Print.everything
        }
    }

    func includeTrip(trip: Trip) -> Bool {
        guard let begin = trip.begin else { return false }
        switch self {
        case .next30Days:
            return begin > Date() && begin < (Date() + 30.days)
        case .nextMonth:
            let nextMonth = Date() + 1.months
            return begin > nextMonth.startOf(component: .month) && begin < nextMonth.endOf(component: .month)
        case .restOfThisYear:
            return begin > Date() && begin < Date().endOf(component: .year)
        case .allFutureTrips:
            return begin > Date()
        case .everything:
            return true
        }
    }
}
