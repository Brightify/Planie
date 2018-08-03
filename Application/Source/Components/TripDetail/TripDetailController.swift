//
//  TripDetailController.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 05/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import RxSwift
import Firebase

final class TripDetailController: ScrollControllerBase<Trip, TripDetailRootView> {

    struct Dependencies {
        let tripService: TripService
    }
    struct Reactions {
        let editTrip: (Trip) -> Observable<Trip>
        let close: () -> Void
        let confirmDestruction: (DestructiveAction) -> Observable<Void>
    }

    private let editButton = UIBarButtonItem(image: UIImage(asset: Asset.edit), style: .plain)
    private let deleteButton = UIBarButtonItem(image: UIImage(asset: Asset.delete), style: .plain)

    private let dependencies: Dependencies
    private let reactions: Reactions
    private let profile: UserProfile

    init(dependencies: Dependencies, reactions: Reactions, profile: UserProfile) {
        self.dependencies = dependencies
        self.reactions = reactions
        self.profile = profile

        super.init()

        navigationItem.rightBarButtonItems = [editButton, deleteButton]

        deleteButton.accessibilityLabel = L10n.Trip.Detail.delete
        editButton.accessibilityLabel = L10n.Trip.Detail.edit
    }

    override func afterInit() {
        editButton.rx.tap
            .withLatestFrom(observableState)
            .flatMapLatest { [reactions] in
                reactions.editTrip($0)
            }
            .subscribe(onNext: setComponentState)
            .disposed(by: lifetimeDisposeBag)

        deleteButton.rx.tap
            .flatMapLatest { [reactions] in
                reactions.confirmDestruction(DeleteTripAction())
            }
            .withLatestFrom(observableState)
            .flatMapLatest { [dependencies, profile] in
                dependencies.tripService.deleteTrip(trip: $0, profile: profile).trackActivity(in: loadingIndicator)
            }
            .subscribe(onNext: { [reactions] in
                reactions.close()
            })
            .disposed(by: lifetimeDisposeBag)
    }
    
    override func update() {
        navigationController?.navigationBar.apply(style: CommonStyles.blueNavigationbar)

        title = componentState.destination?.name

        rootView.componentState = componentState

        if let tripId = componentState.id {
            dependencies.tripService.trip(profile: profile, tripId: tripId)
                .filterError()
                // We want only future updates as we have the current state already (otherwise we create infinite loop)
                .skip(1)
                .subscribe(onNext: { [weak self] in
                    self?.componentState = $0
                })
                .disposed(by: stateDisposeBag)
        }
    }
}
