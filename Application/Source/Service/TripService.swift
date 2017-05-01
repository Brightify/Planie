//
//  TripService.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import Firebase
import FirebaseDatabase
import Reactant
import DataMapper
import Result

final class TripService {
    
    func trips(profile: UserProfile) -> Observable<[Trip]> {
        return FIRDatabase.database().reference().child("trips").child(profile.id)
            .queryOrdered(byChild: "begin")
            .fetchArray()
            .recover([])
    }

    func saveTrip(trip: Trip, profile: UserProfile) -> Observable<Result<Trip, FirebaseStoreError>> {
        return FIRDatabase.database().reference().child("trips").child(profile.id)
            .store(trip)
    }

    func deleteTrip(trip: Trip, profile: UserProfile) -> Observable<Void> {
        return FIRDatabase.database().reference().child("trips").child(profile.id)
            .delete(trip)
            .rewrite(with: ())
    }

    func trip(profile: UserProfile, tripId: String) -> Observable<Result<Trip, FirebaseFetchError>> {
        return FIRDatabase.database().reference().child("trips").child(profile.id)
            .child(tripId)
            .fetch()
    }
}
