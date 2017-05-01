//
//  CityCell.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import Lipstick

final class CityCell: ViewBase<City, Void> {
    
    static let height: CGFloat = 40

    let name = UILabel()
    let location = UILabel()

    override func update() {
        name.text = componentState.name
        location.text = [componentState.region, componentState.country]
            .flatMap { $0 }
            .filter { $0.isNotEmpty }
            .joined(separator: ", ")
    }

}
