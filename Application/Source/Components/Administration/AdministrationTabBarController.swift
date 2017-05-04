//
//  AdminTabBarController.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 07/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import Reactant

class AdministrationTabBarController: UITabBarController {

    init(controllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)

        setViewControllers(controllers, animated: false)

        controllers.forEach {
            let attributes = [Attribute.foregroundColor(.white)].toDictionary()
            $0.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
            $0.tabBarItem.setTitleTextAttributes(attributes, for: .selected)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported!")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBar.barTintColor = Colors.accent
        tabBar.tintColor = .white

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
