//
//  CommonStyles.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import Lipstick
import Reactant

struct CommonStyles {
    static func clearNavigationBar(navigationBar: UINavigationBar) {
        navigationBar.tintColor = .white
        navigationBar.barTintColor = .clear
        navigationBar.backgroundColor = .clear
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.barStyle = .default
    }

    static func blueNavigationbar(navigationBar: UINavigationBar) {
        navigationBar.tintColor = .white
        navigationBar.barTintColor = Colors.accent
        navigationBar.backgroundColor = Colors.accent
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.barStyle = .black
    }

//    static func controllerRootView(container: ControllerRootViewContainer) {
//        container.backgroundColor = Colors.background
//    }
//
//    static func backgroundImage(imageView: UIImageView) {
//        imageView.contentMode = .scaleAspectFill
//        imageView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
//        imageView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
//    }
//
//    static func logo(imageView: UIImageView) {
//        imageView.contentMode = .scaleAspectFit
//    }
}
