//
//  TravelPlannerUITests.swift
//  TravelPlannerUITests
//
//  Created by Tadeáš Kříž on 30/08/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Nimble
import XCTest

class LoginControllerTest: BaseUITestCase {
    
    func testFieldsAndButtonsArePresent() {
        expect(UIElements.Login.email.exists).to(beTrue())
        expect(UIElements.Login.password.exists).to(beTrue())
        expect(UIElements.Login.login.exists).to(beTrue())
        expect(UIElements.Login.signUp.exists).to(beTrue())
    }

    func testCanLoginUser() {
        UITestNavigator.LoginController.login(email: TestConstants.validUser, password: TestConstants.password)
    }

    func testCanLoginModerator() {
        UITestNavigator.LoginController.login(email: TestConstants.validModerator, password: TestConstants.password)

        expect(UIElements.AdministrationTabBar.manageUsers.exists).toEventually(beTrue())
    }

    func testCanLoginAdmin() {
        UITestNavigator.LoginController.login(email: TestConstants.validAdmin, password: TestConstants.password)

        expect(UIElements.AdministrationTabBar.manageUsers.exists).toEventually(beTrue())
    }
}
