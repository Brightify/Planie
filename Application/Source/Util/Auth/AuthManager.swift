//
//  AuthManager.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import Reactant
import Result

final class AuthManager {

    var activeProvider: AuthProvider? {
        for provider in providers.values {
            if provider.active {
                return provider
            }
        }
        return nil
    }
    let authStore: AuthStore

    private let providers: [String: AuthProvider]

    init(authStore: AuthStore, providers: [AuthProvider]) {
        self.authStore = authStore

        var providerDictionary: [String: AuthProvider] = [:]
        for provider in providers {
            providerDictionary[type(of: provider).key] = provider
        }
        self.providers = providerDictionary
    }

    func restoreState() -> Observable<Result<UserProfile, AuthenticationError>> {
        let userInfo = authStore.storedProfile()
        return activeProvider?.restoreState(profile: userInfo) ?? Observable.just(.failure(.unknown))
    }

    func logout() -> Observable<Result<Void, DeauthenticationError>> {
        return (activeProvider?.deleteState() ?? Observable<Result<Void, DeauthenticationError>>.just(.success(())).do(onNext: { [weak self] in
            if case .success = $0 {
                self?.activeProvider?.deactivate()
                self?.authStore.deauthorize()
            }
        }))
    }
}
