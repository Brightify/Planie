//
//  DestructiveAction.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 10/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

protocol DestructiveAction {
    var title: String? { get }
    var message: String? { get }
    var cancelTitle: String { get }
    var destroyTitle: String { get }
}
