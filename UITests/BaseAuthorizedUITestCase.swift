//
//  BaseAuthorizedUITestCase.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Nimble
import XCTest
import Firebase

class BaseAuthorizedUITestCase: BaseUITestCase {
    
    static var user: FIRUser!

    class var authorizeUser: String {
        return TestConstants.validAdmin
    }

    override class func setUp() {
        super.setUp()

        waitUntil(timeout: TestConstants.asyncTimeout) { done in
            FIRAuth.auth()!.signIn(withEmail: authorizeUser, password: TestConstants.password) {
                self.user = $0
                expect($0).toNot(beNil())
                expect($1).to(beNil())
                done()
            }
        }
    }

    override class func tearDown() {
        try! FIRAuth.auth()!.signOut()
        super.tearDown()
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchEnvironment = ["animations": "0"]
        app.launch()
        sleep(1)
    }
}
