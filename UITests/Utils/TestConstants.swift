//
//  TestConstants.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

struct TestConstants {
    static let databaseSecret = "smsTXOfR5oAYCITLIkxye7mU3Gi89zxGyiwMod6P"
    static let databaseUrl = "https://planie-6479c.firebaseio.com/"

    static let password = "planie"

    static let validUser = "planie+user@brightify.org"
    static let validModerator = "planie+moderator@brightify.org"
    static let validAdmin = "planie+admin@brightify.org"

    static let newUser = "planie+user2@brightify.org"

    static let asyncTimeout: TimeInterval = 60
    static let asyncPollInterval: TimeInterval = 0.1
}
