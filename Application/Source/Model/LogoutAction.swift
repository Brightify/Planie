//
//  LogoutAction.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 10/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

struct LogoutAction: DestructiveAction {
    let title: String? = L10n.Auth.confirmLogout
    let message: String? = nil
    let cancelTitle: String = L10n.Common.cancel
    let destroyTitle: String = L10n.Auth.logout
}
