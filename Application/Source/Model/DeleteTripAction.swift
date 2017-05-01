//
//  DeleteTripAction.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 10/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

struct DeleteTripAction: DestructiveAction {
    let title: String? = L10n.Trip.Detail.Confirmdelete.title
    let message: String? = L10n.Trip.Detail.Confirmdelete.message
    let cancelTitle: String = L10n.Common.cancel
    let destroyTitle: String = L10n.Trip.Detail.delete
}
