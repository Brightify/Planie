//
//  CitySelectionRootView.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

final class CitySelectionRootView: PlainTableView<CityCell> {

    init() {
        super.init(
            cellFactory: CityCell.init,
            reloadable: false
        )
        estimatedRowHeight = CityCell.height
        footerView = UIView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
