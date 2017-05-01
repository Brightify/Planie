//
//  PlanieModule.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import DataMapper

final class PlanieModule: DependencyModule {
    // Singletons
    let objectMapper: ObjectMapper
    let authStore: AuthStore
    let userService: UserService
    let loginService: LoginService
    let credentialAuthProvider: CredentialAuthProvider
    let authManager: AuthManager

    // Instances
    var geoNamesService: GeoNamesService {
        return GeoNamesService()
    }

    var tripService: TripService {
        return TripService()
    }

    init() {
        objectMapper = ObjectMapper()
        authStore = AuthStore(objectMapper: objectMapper)
        userService = UserService()
        loginService = LoginService(userService: userService)
        credentialAuthProvider = CredentialAuthProvider(authStore: authStore, loginService: loginService)
        authManager = AuthManager(authStore: authStore, providers: [credentialAuthProvider])
    }
}
