//
//  Validator.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

let loginCredentialsRule: Rule<(email: String, password: String), CredentialsValidationError> = Rule { email, password in
    if let emailError = Rules.String.email.validate(email) {
        return .emailInvalid(emailError)
    }

    guard Rules.String.notEmpty.test(password) else {
        return .passwordEmpty
    }

    guard Rules.String.minLength(1).test(password) else {
        return .passwordTooShort(minLength: 1)
    }

    return nil
}

let registrationCredentialsRule: Rule<(email: String, password: String), CredentialsValidationError> = Rule { email, password in
    if let emailError = Rules.String.email.validate(email) {
        return .emailInvalid(emailError)
    }

    guard Rules.String.notEmpty.test(password) else {
        return .passwordEmpty
    }

    guard Rules.String.minLength(6).test(password) else {
        return .passwordTooShort(minLength: 6)
    }

    return nil
}

let tripValidationRule: Rule<Trip, TripValidationError> = Rule { trip in
    guard trip.destination != nil else {
        return .destinationMissing
    }
    guard trip.begin != nil else {
        return .beginMissing
    }
    guard trip.end != nil else {
        return .endMissing
    }
    guard let tripBegin = trip.begin, let tripEnd = trip.end, tripBegin < tripEnd else {
        return .endBeforeBegin
    }
    return nil
}

enum CredentialsValidationError: Error {
    case emailInvalid(Rules.String.EmailValidationError)
    case passwordEmpty
    case passwordTooShort(minLength: Int)
}

enum TripValidationError: Error {
    case destinationMissing
    case beginMissing
    case endMissing
    case endBeforeBegin
}
