//
//  UserTableRootView.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 07/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//


import Reactant

final class UserTableRootView: PlainTableView<UserCell> {
    
    init() {
        super.init(
            cellFactory: UserCell.init,
            style: UITableViewStyle(rawValue: Int(UserCell.height))!,
            reloadable: false
        )

        height = UserCell.height
        footerView = UIView()
        tableView.separatorColor = Colors.background
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}
