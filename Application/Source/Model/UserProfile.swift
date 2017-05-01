//
//  User.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import DataMapper
import Reactant

struct UserProfile {
    var id: String = ""
    var email: String?
    var role: Role = .user
    var disabled: Bool = false

    init(id: String, email: String?) {
        self.id = id
        self.email = email
    }
}

extension UserProfile: Mappable {
    init(_ data: DeserializableData) throws {
        try mapping(data)
    }

    mutating func mapping(_ data: inout MappableData) throws {
        try data["id"].map(&id)
        data["email"].map(&email)
    }
}
