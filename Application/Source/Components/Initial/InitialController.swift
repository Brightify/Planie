//
//  InitialController.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import RxSwift

final class InitialController: ControllerBase<Void, InitialRootView> {
    struct Dependencies {
        let authManager: AuthManager
    }
    struct Reactions {
        let initComplete: (UserProfile?) -> Void
    }
    
    private let dependencies: Dependencies
    private let reactions: Reactions

    init(dependencies: Dependencies, reactions: Reactions) {
        self.dependencies = dependencies
        self.reactions = reactions

        super.init()
    }

    override func afterInit() {
        dependencies.authManager.restoreState()
            // Run on next tick ensuring the controller gets shown first
            .delaySubscription(0, scheduler: MainScheduler.instance)
            .map { $0.value }
            .subscribe(onNext: reactions.initComplete)
            .addDisposableTo(lifetimeDisposeBag)
    }

    override func update() {
        navigationController?.navigationBar.apply(style: CommonStyles.clearNavigationBar)
        navigationController?.navigationBar.barStyle = .black
    }
}
