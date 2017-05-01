//
//  XCUIApplication+PasteText.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest

extension XCUIApplication {
    /// Needed to workaround a bug in XCTest where text fields could not be written into, thus crashing the test  
    func paste(text: String, to element: XCUIElement) {
        // Sleeps are needed to wait for the UI to catch up with the actions.

        // Bring up the popup menu on the field
        element.doubleTap()

        // Put the value into the pasteboard buffer
        UIPasteboard.general.string = text

        // Wait for the pasted value to get into device properly
        sleep(1)

        // Tap the Paste button to input the password
        menuItems["Paste"].tap()
        // Wait for the paste to complete
        sleep(1)
    }
}
