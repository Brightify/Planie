//
//  UserDetailRootView.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 07/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Lipstick
import Reactant
import Material
import RxSwift

enum UserDetailAction {
    case disableAccount
    case changeRole
    case manageTrips
}

final class UserDetailRootView: ViewBase<UserProfile, UserDetailAction> {

    override var actions: [Observable<UserDetailAction>] {
        return [
            disableAccountButton.rx.tap.rewrite(with: .disableAccount),
            changeRoleButton.rx.tap.rewrite(with: .changeRole),
            manageTripsButton.rx.tap.rewrite(with: .manageTrips),
        ]
    }

    let email = UILabel()
    let role = UILabel()
    let disabled = UILabel()
    let disableAccountButton = FlatButton()
    let changeRoleButton = FlatButton(title: L10n.User.Detail.changeRole.uppercased())
    let manageTripsButton = FlatButton(title: L10n.User.Detail.manageTrips.uppercased())

    private let loggedInUser: UserProfile

    init(loggedInUser: UserProfile) {
        self.loggedInUser = loggedInUser

        super.init()
    }

    override func update() {
        let labelAttributes = [Attribute.foregroundColor(.black), Attribute.font(Fonts.displayLight(size: 14))]
        let valueAttributes = [Attribute.foregroundColor(.black), Attribute.font(Fonts.displayRegular(size: 14))]

        email.attributedText = L10n.User.Detail.emailLabel.attributed(labelAttributes) +
            ": \(componentState.email ?? "-")".attributed(valueAttributes)

        role.attributedText = L10n.User.Detail.roleLabel.attributed(labelAttributes) +
            ": \(componentState.role.localizedName)".attributed(valueAttributes)

        disabled.attributedText = L10n.User.Detail.disabledLabel.attributed(labelAttributes) +
            ": \(componentState.disabled ? L10n.User.Detail.Disabled.true : L10n.User.Detail.Disabled.false)"
                .attributed(valueAttributes)

        disableAccountButton.setTitle(componentState.disabled ?
            L10n.User.Detail.enableAccount.uppercased() : L10n.User.Detail.disableAccount.uppercased(),
                                      for: .normal)

        disableAccountButton.isHidden = loggedInUser.role != .admin && componentState.role == .admin
        changeRoleButton.isHidden = loggedInUser.role != .admin
        manageTripsButton.isHidden = loggedInUser.role != .admin
    }
}
