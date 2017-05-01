//
//  BaseUITestCase.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Nimble
import XCTest
import Firebase

class BaseUITestCase: XCTestCase {
    
    let app = XCUIApplication()

    func waitWhileLoading() {
        expect(UIElements.loading.exists).toEventually(beFalse())
    }

    override class func setUp() {
        Nimble.AsyncDefaults.Timeout = TestConstants.asyncTimeout
        Nimble.AsyncDefaults.PollInterval = TestConstants.asyncPollInterval

        FIRApp.configure()
    }

    override class func tearDown() {
        waitUntil(timeout: TestConstants.asyncTimeout) { done in
            FIRApp.defaultApp()?.delete { _ in done() }
        }
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchEnvironment = ["animations": "0"]
        app.launch()
        sleep(1)
        expect(UITestNavigator.initializing).toEventually(beFalse())
        sleep(3)
        // Logout in case we are logged in
        if UIElements.Trips.logout.exists {
            // First we tap the logout barButton
            UIElements.Trips.logout.tap()
            // Wait for the dialog to appear
            expect(UIElements.Trips.confirmLogout.exists).toEventually(beTrue())
            // Then we tap the logout button in alert
            UIElements.Trips.confirmLogout.tap()
            waitUntil(timeout: TestConstants.asyncTimeout) { done in
                if UITestNavigator.LoginController.open {
                    done()
                }
            }
        }
    }
}
