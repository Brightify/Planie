//
//  DependencyModule.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import DataMapper

protocol DependencyModule {
    var objectMapper: ObjectMapper { get }
    var authStore: AuthStore { get }
    var loginService: LoginService { get }
    var credentialAuthProvider: CredentialAuthProvider { get }
    var authManager: AuthManager { get }
    var geoNamesService: GeoNamesService { get }
    var tripService: TripService { get }
    var userService: UserService { get }
}
