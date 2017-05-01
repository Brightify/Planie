//
//  UIElements.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest

struct UIElements {

    static let loading = XCUIApplication().staticTexts["Loading .."]

    struct Login {
        static let email = XCUIApplication().textFields["Email"]
        static let password = XCUIApplication().secureTextFields["Password"]
        static let login = XCUIApplication().buttons["LOG IN"]
        static let signUp = XCUIApplication().buttons["SIGN UP"]
    }

    struct Registration {
        static let email = XCUIApplication().textFields["Email"]
        static let password = XCUIApplication().secureTextFields["Password"]
        static let signUp = XCUIApplication().buttons["SIGN UP"]
    }

    struct Trips {
        static let logout = XCUIApplication().navigationBars.element(boundBy: 0).buttons["Log out"]
        static let printItinerary = XCUIApplication().navigationBars.element(boundBy: 0).buttons["Print itinerary"]
        static let createTrip = XCUIApplication().navigationBars.element(boundBy: 0).buttons["Create trip"]
        static let tripTable = XCUIApplication().tables.element(boundBy: 0)
        static let confirmLogout = XCUIApplication().alerts.element.buttons["Log out"]
    }

    struct CreateTrip {
        static let selectDestination = XCUIApplication().buttons["Select destination"]
        static let save = XCUIApplication().navigationBars.element(boundBy: 0).buttons["Save"]
        static let cancel = XCUIApplication().navigationBars.element(boundBy: 0).buttons["Cancel"]
        static let begin = XCUIApplication().textFields["Begin"]
        static let end = XCUIApplication().textFields["End"]
        static let comment = XCUIApplication().textViews["Comment"]
    }

    struct TripDetail {
        static let delete = XCUIApplication().navigationBars.element.buttons["Delete trip"]
        static let edit = XCUIApplication().navigationBars.element.buttons["Edit trip"]
        static let confirmDelete = XCUIApplication().alerts.element.buttons["Delete trip"]
    }

    struct SelectCity {
        static let searchCity = XCUIApplication().navigationBars.element(boundBy: 0).textFields.element(boundBy: 0)
        static func cityWithName(name: String) -> XCUIElement? {
            let cells = XCUIApplication().tables.element(boundBy: 0).cells
            return cells.allElementsBoundByIndex.first(where: { $0.staticTexts[name].exists })
        }
    }

    struct AdministrationTabBar {
        static let myTrips = XCUIApplication().tabBars.element(boundBy: 0).buttons["My trips"]
        static let manageUsers = XCUIApplication().tabBars.element(boundBy: 0).buttons["Manage users"]
    }

    struct UserTable {
        static let userTable = XCUIApplication().tables.element(boundBy: 0)
    }

    struct UserDetail {
        static let disableAccount = XCUIApplication().buttons["DISABLE ACCOUNT"]
        static let enableAccount = XCUIApplication().buttons["ENABLE ACCOUNT"]
        static let changeRole = XCUIApplication().buttons["CHANGE ROLE"]
        static let manageTrips = XCUIApplication().buttons["MANAGE TRIPS"]
        static let roleSheet = XCUIApplication().sheets.element
    }
}
