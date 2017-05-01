//
//  UserTableController.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 07/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import DataMapper
import RxSwift
import RxCocoa
import Lipstick
import SwiftDate

final class UserTableController: ControllerBase<[UserProfile], UserTableRootView> {

    struct Dependencies {
        let userService: UserService
        let authManager: AuthManager
    }
    struct Reactions {
        let openUser: (UserProfile) -> Void
        let loggedOut: (() -> Void)?
        let confirmDestruction: (DestructiveAction) -> Observable<Void>
    }

    private let dependencies: Dependencies
    private let reactions: Reactions
    private let loggedInUser: UserProfile

    private let logout = UIBarButtonItem(title: L10n.Auth.logout, style: .plain)

    init(dependencies: Dependencies, reactions: Reactions, loggedInUser: UserProfile) {
        self.dependencies = dependencies
        self.reactions = reactions
        self.loggedInUser = loggedInUser
        
        super.init(title: L10n.User.List.title)

        if reactions.loggedOut != nil {
            navigationItem.leftBarButtonItem = logout
        }

        rootView.componentState = .loading

        tabBarItem = UITabBarItem(title: L10n.User.List.tabTitle,
                                  image: UIImage(asset: Asset.users),
                                  selectedImage: UIImage(asset: Asset.usersSelected))
    }

    override func afterInit() {
        logout.rx.tap
            .flatMapLatest { [reactions] in
                reactions.confirmDestruction(LogoutAction())
            }
            .flatMapLatest { [dependencies] in
                dependencies.authManager.logout().trackActivity(in: loadingIndicator)
            }
            .subscribe(onNext: { [reactions] _ in
                reactions.loggedOut?()
            })
            .addDisposableTo(lifetimeDisposeBag)

        dependencies.userService.users()
            .map { [loggedInUser] in $0.filter { $0.id != loggedInUser.id } }
            .subscribe(onNext: setComponentState)
            .addDisposableTo(lifetimeDisposeBag)
    }

    override func update() {
        navigationController?.navigationBar.apply(style: CommonStyles.blueNavigationbar)

        let users = componentState
        rootView.componentState = users.isNotEmpty ? .items(users) : .empty(message: L10n.User.List.empty)
    }
    
    override func act(on action: UserTableRootView.ActionType) {
        switch action {
        case .refresh:
            invalidate()
        case .selected(let user):
            reactions.openUser(user)
        case .rowAction:
            break
        }
    }
}
