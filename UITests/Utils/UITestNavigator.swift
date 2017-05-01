//
//  UITestNavigator.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import Nimble
import SwiftDate

struct UITestNavigator {
    static var initializing: Bool {
        return XCUIApplication().activityIndicators["Application is initializing"].exists
    }

    struct LoginController {
        static let elements = UIElements.Login.self

        static var open: Bool {
            return UIElements.Login.login.exists
        }

        static func openRegistration() -> RegistrationController.Type {
            UIElements.Login.signUp.tap()
            return RegistrationController.self
        }

        static func login(email: String, password: String) -> TripTableController.Type {
            let app = XCUIApplication()
            app.paste(text: email, to: UIElements.Login.email)
            app.paste(text: password, to: UIElements.Login.password)
            UIElements.Login.login.tap()
            let logout = app.navigationBars.element(boundBy: 0).buttons["Log out"]
            expect(logout.exists).toEventually(beTrue())
            return TripTableController.self
        }

        static func loginManagement(email: String, password: String) -> AdministrationTabBarController.Type {
            login(email: email, password: password)
            return AdministrationTabBarController.self
        }
    }

    struct RegistrationController {
        static let elements = UIElements.Registration.self
    }

    struct TripTableController {
        static let elements = UIElements.Trips.self

        static func createTrip() -> CreateTripController.Type {
            elements.createTrip.tap()
            return CreateTripController.self
        }

        static func openTripDetail(row: Int) -> TripDetailController.Type {
            elements.tripTable.cells.element(boundBy: UInt(row)).tap()
            return TripDetailController.self
        }
    }

    struct CreateTripController {
        static let elements = UIElements.CreateTrip.self

        static func selectDestination(name: String) -> CreateTripController.Type {
            elements.selectDestination.tap()
            XCUIApplication().paste(text: name, to: UIElements.SelectCity.searchCity)
            expect(XCUIApplication().tables.element(boundBy: 0).cells.count).toEventually(beGreaterThan(0))
            UIElements.SelectCity.cityWithName(name: name)!.tap()
            sleep(1)
            return self
        }

        static func setDate(begin: Date, fromBegin oldBegin: Date? = nil,
                                  end: Date, fromEnd oldEnd: Date? = nil) -> CreateTripController.Type {
            elements.begin.tap()
            changeDatePicker(picker: XCUIApplication().datePickers.element, from: oldBegin ?? Date(), to: begin)
            elements.end.tap()
            changeDatePicker(picker: XCUIApplication().datePickers.element, from: oldEnd ?? begin, to: end)
            return self
        }

        static func set(comment: String) -> CreateTripController.Type {
            XCUIApplication().paste(text: comment, to: elements.comment)
            return self
        }

        private static func changeDatePicker(picker: XCUIElement, from: Date, to: Date) {
            expect(picker.exists).toEventually(beTrue())
            
            let monthPicker = picker.pickerWheels[from.monthName]
            let dayPicker = picker.pickerWheels["\(from.day)"]
            let yearPicker = picker.pickerWheels["\(from.year)"]

            yearPicker.adjust(toPickerWheelValue: "\(to.year)")
            monthPicker.adjust(toPickerWheelValue: to.monthName)
            dayPicker.adjust(toPickerWheelValue: "\(to.day)")
        }
    }

    struct TripDetailController {
        static let elements = UIElements.TripDetail.self
    }

    struct AdministrationTabBarController {
        static let elements = UIElements.AdministrationTabBar.self
    }

    struct UserTableController {
        static let elements = UIElements.UserTable.self

        static func openUserDetail(email: String) -> UserDetailController.Type {
            expect(elements.userTable.cells.count).toEventually(beGreaterThan(0))
            elements.userTable.cells.allElementsBoundByIndex.first(where: { $0.staticTexts[email].exists })!.tap()
            return UserDetailController.self
        }
    }

    struct UserDetailController {
        static let elements = UIElements.UserDetail.self

        static func set(role: String) -> UserDetailController.Type {
            elements.changeRole.tap()
            expect(elements.roleSheet.exists).toEventually(beTrue())
            elements.roleSheet.buttons[role].tap()
            return self
        }

        static func manageTrips() -> TripTableController.Type {
            elements.manageTrips.tap()
            return TripTableController.self
        }
    }
}
