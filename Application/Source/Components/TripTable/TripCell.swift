//
//  TripCell.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import Lipstick
import SwiftDate
import MapKit

final class TripCell: ViewBase<Trip, Void> {
    
    static let height: CGFloat = 148

    let container = ContainerView()
    let map = StaticMap()
    let destination = UILabel()
    let date = UILabel()

    override func update() {
        destination.text = componentState.destination?.fullAddress
        date.text = componentState.dateRangeWithCountdown
        map.componentState = componentState.destination?.boundingBox?.mapRegion ?? MKCoordinateRegion()
    }

    override func loadView() {
        container.backgroundColor = Colors.accent
    }
}
