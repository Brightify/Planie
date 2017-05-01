//
//  CreateTripController.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import DataMapper
import RxSwift
import RxCocoa
import Material

enum CreateTripControllerMode {
    case create
    case edit
}

final class CreateTripController: ScrollControllerBase<Trip, CreateTripRootView> {
    struct Dependencies {
        let tripService: TripService
    }
    struct Reactions {
        let selectCity: (String) -> Observable<City>
        let close: () -> Void
        let tripSaved: (Trip) -> Void
    }

    private let dependencies: Dependencies
    private let reactions: Reactions
    private let profile: UserProfile
    private let mode: CreateTripControllerMode

    private let saveTrip = UIBarButtonItem(barButtonSystemItem: .save)

    init(dependencies: Dependencies, reactions: Reactions, profile: UserProfile, mode: CreateTripControllerMode) {
        self.dependencies = dependencies
        self.reactions = reactions
        self.profile = profile
        self.mode = mode

        super.init(title: mode == .create ? L10n.Trip.Create.title : L10n.Trip.Edit.title,
                   root: CreateTripRootView(mode: mode))

        navigationItem.rightBarButtonItem = saveTrip
    }

    override func afterInit() {
        let validatedTrip = saveTrip.rx.tap
            .withLatestFrom(observableState)
            .map(tripValidationRule.run)
            .shareReplay(1)

        validatedTrip.errorOnly()
            .map { error -> String in
                switch error {
                case .destinationMissing:
                    return L10n.Trip.Create.Error.destinationMissing
                case .beginMissing:
                    return L10n.Trip.Create.Error.beginMissing
                case .endMissing:
                    return L10n.Trip.Create.Error.endMissing
                case .endBeforeBegin:
                    return L10n.Trip.Create.Error.endBeforeBegin
                }
            }
            .subscribe(onNext: {
                _ = errorAlert(title: L10n.Trip.Edit.Error.title, subTitle: $0)
            })
            .addDisposableTo(lifetimeDisposeBag)

        let tripSave = validatedTrip
            .filterError()
            .flatMapLatest { [dependencies, profile] in
                dependencies.tripService.saveTrip(trip: $0, profile: profile).trackActivity(in: loadingIndicator)
            }
            .shareReplay(1)

        tripSave.errorOnly()
            .subscribe(onNext: { [mode] _ in
                _ = errorAlert(title: mode == .create ? L10n.Trip.Create.Error.title : L10n.Trip.Edit.Error.title,
                               subTitle: L10n.Common.tryAgainLater)
            })
            .addDisposableTo(lifetimeDisposeBag)

        tripSave.filterError()
            .subscribe(onNext: { [reactions] in
                reactions.tripSaved($0)
            })
            .addDisposableTo(lifetimeDisposeBag)
    }

    override func update() {
        navigationController?.navigationBar.apply(style: CommonStyles.blueNavigationbar)

        rootView.componentState = componentState
    }
    
    override func act(on action: CreateTripRootView.ActionType) {
        switch action {
        case .selectDestination:
            reactions.selectCity(componentState.destination?.name ?? "")
                .subscribe(onNext: { [weak self] in
                    self?.componentState.destination = $0
                })
                .addDisposableTo(lifetimeDisposeBag)
        case .beginDate(let begin):
            componentState.begin = begin.startOf(component: .day)
        case .endDate(let end):
            componentState.end = end.endOf(component: .day)
        case .commentText(let comment):
            componentState.comment = comment
        }
    }
}
