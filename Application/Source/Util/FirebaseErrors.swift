//
//  FirebaseErrors.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 06/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Firebase

enum FirebaseCommonError: Error {
    case networkError
    case userNotFound
    case userTokenExpired
    case tooManyRequests
    case invalidAPIKey
    case appNotAuthorized
    case keychainError
    case internalError
    case unknown

    init(error: NSError) {
        let firebaseError = FIRAuthErrorCode(rawValue: error.code)

        switch firebaseError {
        case .errorCodeNetworkError?:
            self = .networkError
        case .errorCodeUserNotFound?:
            self = .userNotFound
        case .errorCodeUserTokenExpired?:
            self = .userTokenExpired
        case .errorCodeTooManyRequests?:
            self = .tooManyRequests
        case .errorCodeInvalidAPIKey?:
            self = .invalidAPIKey
        case .errorCodeAppNotAuthorized?:
            self = .appNotAuthorized
        case .errorCodeKeychainError?:
            self = .keychainError
        case .errorCodeInternalError?:
            self = .internalError
        default:
            self = .unknown
        }
    }
}

enum FirebaseLoginError: Error {
    case common(FirebaseCommonError)
    case operationNotAllowed
    case userDisabled
    case wrongPassword

    init(error: NSError) {
        let firebaseError = FIRAuthErrorCode(rawValue: error.code)

        switch firebaseError {
        case .errorCodeOperationNotAllowed?:
            self = .operationNotAllowed
        case .errorCodeUserDisabled?:
            self = .userDisabled
        case .errorCodeWrongPassword?:
            self = .wrongPassword
        default:
            self = .common(FirebaseCommonError(error: error))
        }
    }
}

enum FirebaseSignupError: Error {
    case common(FirebaseCommonError)
    case invalidEmail
    case emailAlreadyInUse
    case operationNotAllowed
    case weakPassword(reason: String)

    init(error: NSError) {
        let firebaseError = FIRAuthErrorCode(rawValue: error.code)

        switch firebaseError {
        case .errorCodeInvalidEmail?:
            self = .invalidEmail
        case .errorCodeEmailAlreadyInUse?:
            self = .emailAlreadyInUse
        case .errorCodeOperationNotAllowed?:
            self = .operationNotAllowed
        case .errorCodeWeakPassword?:
            let reason = error.userInfo[NSLocalizedFailureReasonErrorKey] as? String ?? ""
            self = .weakPassword(reason: reason)
        default:
            self = .common(FirebaseCommonError(error: error))
        }
    }
}
