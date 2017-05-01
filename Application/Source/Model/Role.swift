//
//  Role.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

enum Role {
    case user
    case moderator
    case admin
}

extension Role {

    static var allRoles: [Role] {
        return [.user, .moderator, .admin]
    }

    var localizedName: String {
        switch self {
        case .user:
            return L10n.Role.user
        case .moderator:
            return L10n.Role.moderator
        case .admin:
            return L10n.Role.admin
        }
    }
}
