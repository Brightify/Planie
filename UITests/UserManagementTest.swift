//
//  UserManagementTest.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 10/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Nimble
import XCTest
import Firebase
import SwiftDate
import RxNimble
import Reactant
import Fetcher

class UserManagementTest: BaseAuthorizedUITestCase {
    
    let fetcher: Fetcher = {
        let fetcher = Fetcher(requestPerformer: AlamofireRequestPerformer())
        fetcher.register(requestEnhancers: RequestLogger(defaultOptions: RequestLogging.all))
        fetcher.register(requestModifiers: BaseUrl(baseUrl: TestConstants.databaseUrl))
        return fetcher
    }()

    override class var authorizeUser: String {
        return TestConstants.validUser
    }

    override func setUp() {
        super.setUp()

        UITestNavigator.LoginController
            .loginManagement(email: TestConstants.validAdmin, password: TestConstants.password)
            .elements.manageUsers.tap()
    }

    func testCanChangeRole() {
        let target = TestConstants.validUser

        let user = type(of: self).user
        func isModerator() -> Bool {
            let endpoint = GET<Void, Bool>("/moderators/\(user?.uid).json?auth=\(TestConstants.databaseSecret)")
            let value = try! fetcher.rx.request(endpoint)
                .map { $0.result.value }.toBlocking().single()?.flatMap { $0 }

            return value ?? false
        }
        func isAdmin() -> Bool {
            let endpoint = GET<Void, Bool>("/admins/\(user?.uid).json?auth=\(TestConstants.databaseSecret)")
            let value = try! fetcher.rx.request(endpoint)
                .map { $0.result.value }.toBlocking().single()?.flatMap { $0 }

            return value ?? false
        }
        let detail = UITestNavigator.UserTableController.openUserDetail(email: target)

        expect(isModerator()).to(beFalse())
        expect(isAdmin()).to(beFalse())

        detail.set(role: "Moderator")
        waitWhileLoading()

        expect(isModerator()).to(beTrue())
        expect(isAdmin()).to(beFalse())

        detail.set(role: "Administrator")
        waitWhileLoading()

        expect(isModerator()).to(beFalse())
        expect(isAdmin()).to(beTrue())

        detail.set(role: "User")
        waitWhileLoading()

        expect(isModerator()).to(beFalse())
        expect(isAdmin()).to(beFalse())
    }

    func testCanDisableAccount() {
        let target = TestConstants.validUser

        let user = type(of: self).user
        func isDisabled() -> Bool {
            let endpoint = GET<Void, Bool>("/disabledUsers/\(user?.uid).json?auth=\(TestConstants.databaseSecret)")
            let value = try! fetcher.rx.request(endpoint)
                .map { $0.result.value }.toBlocking().single()?.flatMap { $0 }

            return value ?? false
        }
        let detail = UITestNavigator.UserTableController.openUserDetail(email: target)

        expect(isDisabled()).to(beFalse())

        detail.elements.disableAccount.tap()
        waitWhileLoading()

        expect(isDisabled()).to(beTrue())

        detail.elements.enableAccount.tap()
        waitWhileLoading()

        expect(isDisabled()).to(beFalse())
    }
}
