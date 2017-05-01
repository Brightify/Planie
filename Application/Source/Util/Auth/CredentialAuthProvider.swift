//
//  CredentialAuthProvider.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import SwiftKeychainWrapper
import Reactant
import Result

final class CredentialAuthProvider: AuthProvider {

    private static let emailKey = "email"
    private static let passwordKey = "password"

    static let key: String = "credential"

    private let authStore: AuthStore
    private let loginService: LoginService

    init(authStore: AuthStore, loginService: LoginService) {
        self.authStore = authStore
        self.loginService = loginService
    }

    func login(email: String, password: String) -> Observable<Result<UserProfile, FirebaseLoginError>> {
        return loginService.login(email: email, password: password)
            .take(1)
            .do(onNext: {
                guard let value = $0.value else { return }
                self.authStore.authorize(with: value)
                self.saveState(email: email, password: password)
        })
    }

    func register(email: String, password: String) -> Observable<Result<UserProfile, FirebaseSignupError>> {
        return loginService.register(email: email, password: password)
            .take(1)
            .do(onNext: {
                guard let value = $0.value else { return }
                self.authStore.authorize(with: value)
                self.saveState(email: email, password: password)
        })
    }

    func saveState(email: String, password: String) {
        activate()

        KeychainWrapper.standard.set(email, forKey: CredentialAuthProvider.emailKey)
        KeychainWrapper.standard.set(password, forKey: CredentialAuthProvider.passwordKey)
    }

    func restoreState(profile: UserProfile?)
        -> Observable<Result<UserProfile, AuthenticationError>> {
            if let
                email = KeychainWrapper.standard.string(forKey: CredentialAuthProvider.emailKey),
                let password = KeychainWrapper.standard.string(forKey: CredentialAuthProvider.passwordKey) {
                return login(email: email, password: password).mapError(AuthenticationError.firebaseError)
            } else {
                deactivate()
                #if DEBUG
                    fatalError("Credentials are not stored before restore is called!!!")
                #else
                    return Observable.just(.Failure(.Unknown))
                #endif
            }
    }

    func deleteState() -> Observable<Result<Void, DeauthenticationError>> {
        KeychainWrapper.standard.removeObject(forKey: CredentialAuthProvider.emailKey)
        KeychainWrapper.standard.removeObject(forKey: CredentialAuthProvider.passwordKey)

        return loginService.logout().mapError(DeauthenticationError.firebaseError)
    }
}
