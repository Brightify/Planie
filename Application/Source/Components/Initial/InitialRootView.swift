//
//  InitialRootView.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

import Material
import RxSwift

final class InitialRootView: ViewBase<Void, Void>{
    
    let indicator = UIActivityIndicatorView()

    override func update() {
    }

    override func loadView() {
        indicator.accessibilityLabel = L10n.App.initializing
        indicator.startAnimating()
    }
}
