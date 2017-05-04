//
//  TripDetailRootView.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 08/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import MapKit

import Reactant

final class TripDetailRootView: ViewBase<Trip, Void> {
    
    let map = StaticMap()
    let destination = UILabel()
    let date = UILabel()

    let commentContainer = ContainerView()
    let comment = UILabel()

    override func update() {
        map.componentState = componentState.destination?.boundingBox?.mapRegion ?? MKCoordinateRegion()

        let labelAttributes = [Attribute.foregroundColor(.black), Attribute.font(Fonts.displayLight(size: 14))]
        let valueAttributes = [Attribute.foregroundColor(.black), Attribute.font(Fonts.displayRegular(size: 14))]
        let commentAttributes = [Attribute.foregroundColor(.black), Attribute.font(Fonts.textRegular(size: 14))]

        destination.attributedText = L10n.Trip.destination.attributed(labelAttributes) +
            ": \(componentState.destination?.fullAddress ?? "-")".attributed(valueAttributes)

        date.attributedText = L10n.Trip.Detail.date.attributed(labelAttributes) +
            ": \(componentState.dateRangeWithCountdown)".attributed(valueAttributes)

        comment.attributedText = L10n.Trip.comment.attributed(labelAttributes) +
            "\n" +
            "\(componentState.comment)".attributed(commentAttributes)

        commentContainer.isHidden = componentState.comment.isEmpty
    }

}
