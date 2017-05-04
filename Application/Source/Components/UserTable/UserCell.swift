//
//  UserCell.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 07/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

import SwiftDate
import MapKit

final class UserCell: ViewBase<UserProfile, Void>, TableViewCell {
    
    static let height: CGFloat = 60

    let email = UILabel()
    let properties = UILabel()

    override func update() {
        email.text = componentState.email

        properties.text = [componentState.role.localizedName,
                           componentState.disabled ? L10n.User.List.disabled : ""]
            .filter { $0.isNotEmpty }
            .joined(separator: ", ")
    }

    func setHighlighted(highlighted: Bool, animated: Bool) {
        let style = { self.apply(style: highlighted ? Styles.highlighted : Styles.base) }

        if animated {
            UIView.animate(withDuration: 0.3, animations: style)
        } else {
            style()
        }
    }

    override func loadView() {
        apply(style: Styles.base)
    }
}

extension UserCell {
    fileprivate struct Styles {
        static func base(cell: UserCell) {
            cell.backgroundColor = .white
        }

        static func highlighted(cell: UserCell) {
            cell.backgroundColor = UIColor.white.darker(by: 10%)
        }
    }
}
