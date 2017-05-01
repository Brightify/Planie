//
//  RegistrationControllerTest.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Nimble
import XCTest
import Firebase

class RegistrationControllerTest: BaseUITestCase {
    
    override func setUp() {
        super.setUp()
        UITestNavigator.LoginController.openRegistration()
    }

    func testFieldsAndButtonsArePresent() {
        expect(UIElements.Registration.email.exists).to(beTrue())
        expect(UIElements.Registration.password.exists).to(beTrue())
        expect(UIElements.Registration.signUp.exists).to(beTrue())
    }

    func testCanRegister() {
        app.paste(text: TestConstants.newUser, to: UIElements.Registration.email)
        app.paste(text: TestConstants.password, to: UIElements.Registration.password)
        UIElements.Registration.signUp.tap()
        expect(UIElements.Trips.logout.exists).toEventually(beTrue())
        
        FIRAuth.auth()?.signIn(withEmail: TestConstants.newUser, password: TestConstants.password, completion: nil)

        expect(FIRAuth.auth()?.currentUser).toEventuallyNot(beNil())

        let uid = FIRAuth.auth()!.currentUser!.uid
        waitUntil(timeout: TestConstants.asyncTimeout) { done in
            FIRDatabase.database().reference().child("users").child(uid).removeValue { _ in
                done()
            }
        }

        FIRAuth.auth()?.currentUser?.delete(completion: nil)

        expect(FIRAuth.auth()?.currentUser).toEventually(beNil())

    }
}
