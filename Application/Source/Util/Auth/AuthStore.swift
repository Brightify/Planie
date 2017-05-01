//
//  AuthStore.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import SwiftKeychainWrapper
import DataMapper
import Reactant

final class AuthStore {
    
    private static let profileKey = "AuthStore.Profile"

    var authorization: Observable<Authorization> {
        return authorizationSubject
    }

    private let authorizationSubject: BehaviorSubject<Authorization> = BehaviorSubject(value: .unauthenticated)
    private let jsonSerializer = JsonSerializer()
    private let objectMapper: ObjectMapper

    init(objectMapper: ObjectMapper) {
        self.objectMapper = objectMapper
    }

    func authorize(with profile: UserProfile) {
        storeProfile(profile: profile)
        authorizationSubject.onNext(.authenticated(profile))
    }

    func deauthorize() {
        deleteUserInfo()
        authorizationSubject.onNext(.unauthenticated)
    }

    func storedProfile() -> UserProfile? {
        if let jsonData = KeychainWrapper.standard.data(forKey: AuthStore.profileKey) {
            return objectMapper.deserialize(jsonSerializer.deserialize(jsonData))
        } else {
            return nil
        }
    }

    private func storeProfile(profile: UserProfile) {
        let jsonData = jsonSerializer.serialize(objectMapper.serialize(profile))
        KeychainWrapper.standard.set(jsonData, forKey: AuthStore.profileKey)
    }

    private func deleteUserInfo() {
        KeychainWrapper.standard.removeObject(forKey: AuthStore.profileKey)
    }
}
