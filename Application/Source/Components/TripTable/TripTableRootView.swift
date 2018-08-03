//
//  TripTableRootView.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//


import Reactant
import RxSwift

final class TripTableRootView: PlainTableView<TripCell> {
    
    override var edgesForExtendedLayout: UIRectEdge {
        return []
    }

    @objc
    init() {
        super.init(cellFactory: TripCell.init)

        tableView.rowHeight = TripCell.height
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView() //this line makes searchbarwrapper disappear
        tableView.contentInset.bottom = 8
    }
}
