//
//  UserDetailController.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 07/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import DataMapper
import RxSwift
import RxCocoa


final class UserDetailController: ControllerBase<UserProfile, UserDetailRootView> {

    struct Dependencies {
        let userService: UserService
    }
    struct Reactions {
        let openTrips: (UserProfile) -> Void
        let selectRole: (Role) -> Observable<Role>
    }

    private let dependencies: Dependencies
    private let reactions: Reactions
    private let loggedInUser: UserProfile
    private let shownProfileId: String

    init(dependencies: Dependencies,
         reactions: Reactions,
         loggedInUser: UserProfile,
         shownProfile: UserProfile) {
        self.dependencies = dependencies
        self.reactions = reactions
        self.loggedInUser = loggedInUser
        self.shownProfileId = shownProfile.id

        super.init(title: L10n.User.Detail.title, root: UserDetailRootView(loggedInUser: loggedInUser))

        rootView.componentState = shownProfile
        hidesBottomBarWhenPushed = true
    }

    override func afterInit() {
        dependencies.userService.userProfile(userId: shownProfileId)
            .filterError()
            .subscribe(onNext: setComponentState)
            .disposed(by: lifetimeDisposeBag)
    }

    override func update() {
        navigationController?.navigationBar.apply(style: CommonStyles.blueNavigationbar)

        rootView.componentState = componentState
    }

    override func act(on action: UserDetailAction) {
        let profile = componentState
        switch action {
        case .disableAccount:
            dependencies.userService.setAccountDisabled(user: profile, disabled: !profile.disabled)
                .trackActivity(in: loadingIndicator)
                .subscribe()
                .disposed(by: lifetimeDisposeBag)

        case .changeRole:
            reactions.selectRole(profile.role)
                .flatMapLatest { [dependencies] in
                    dependencies.userService.setAccountRole(user: profile, role: $0).trackActivity(in: loadingIndicator)
                }
                .subscribe()
                .disposed(by: lifetimeDisposeBag)
        case .manageTrips:
            reactions.openTrips(profile)
        }
    }
}
