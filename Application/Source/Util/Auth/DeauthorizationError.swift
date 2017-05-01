//
//  DeauthorizationError.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

enum DeauthenticationError: Error {
    case firebaseError(FirebaseCommonError)
    case unknown
}
