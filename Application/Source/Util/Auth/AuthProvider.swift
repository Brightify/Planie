//
//  AuthProvider.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import DataMapper
import Fetcher
import Reactant
import Result

// Thanks to this we won't need to create a new instance every time.
// swiftlint:disable variable_name
let RequiresAuth = RequiresAuthModifier()
struct RequiresAuthModifier: RequestModifier { }

private let usernameKey = "username"
private let passwordKey = "password"
private let authTypeKey = "authType"

typealias DeviceToken = String

enum Authorization {
    case authenticated(UserProfile)
    case unauthenticated

    var authorized: Bool {
        switch self {
        case .authenticated:
            return true
        case .unauthenticated:
            return false
        }
    }

    var email: String? {
        switch self {
        case .authenticated(let user):
            return user.email
        case .unauthenticated:
            return nil
        }
    }
}

import SwiftKeychainWrapper

private let activeAuthProviderKey = "activeAuthProvider"

protocol AuthProvider {
    static var key: String { get }

    var active: Bool { get }

    func restoreState(profile: UserProfile?) -> Observable<Result<UserProfile, AuthenticationError>>

    func deleteState() -> Observable<Result<Void, DeauthenticationError>>

    func activate()

    func deactivate()
}

extension AuthProvider {
    var active: Bool {
        return KeychainWrapper.standard.string(forKey: activeAuthProviderKey) == Self.key
    }

    func activate() {
        KeychainWrapper.standard.set(Self.key, forKey: activeAuthProviderKey)
    }

    func deactivate() {
        KeychainWrapper.standard.removeObject(forKey: activeAuthProviderKey)
    }
}
