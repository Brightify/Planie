//
//  AppDelegate.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 30/08/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import SuperDelegate
import IQKeyboardManagerSwift
import Reactant
import Firebase
import DataMapper
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: SuperDelegate, ApplicationLaunched {

    let window = UIWindow()

    func setupApplication() {
        Fabric.with([Crashlytics.self, Answers.self])
        disableAnimationsIfRequested()
        FIRApp.configure()
        IQKeyboardManager.shared.enable = true

//        Configuration.global.set(value: L10n.Common.loading, for: Properties.)
//        ReactantConfiguration.global.defaultLoadingMessage = L10n.Common.loading
        Configuration.global.set(Properties.Style.controllerRoot, to: GeneralStyles.controllerRootView)
    }

    public func loadInterface(launchItem: LaunchItem) {
        setup(mainWindow: window)

        let module = PlanieModule()
        let wireframe = MainWireframe(module: module)
        window.rootViewController = wireframe.entrypoint()

        activateLiveReload(in: window)
    }

    /// A way to speed up UI tests by disabling animations
    func disableAnimationsIfRequested() {
        // NOTE: This makes the UISearchBar move under statusBar when activated.
        if ProcessInfo.processInfo.environment["animations"] == "0" {
            UIView.setAnimationsEnabled(false)
        }
    }
}
