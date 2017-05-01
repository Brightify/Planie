//
//  TripTableController.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import DataMapper
import RxSwift
import RxCocoa
import Lipstick
import SwiftDate

final class TripTableController: ControllerBase<Void, TripTableRootView>, UITableViewDelegate {
    struct Dependencies {
        let tripService: TripService
        let authManager: AuthManager
    }
    struct Reactions {
        let createTrip: () -> Observable<Trip>
        let openTrip: (Trip) -> Void
        let loggedOut: (() -> Void)?
        let selectPrintInterval: ([PrintUtils.IntervalWithTrips]) -> Observable<PrintUtils.IntervalWithTrips>
        let printItinerary: (String) -> Observable<Void>
        let confirmDestruction: (DestructiveAction) -> Observable<Void>
    }
    
    private let dependencies: Dependencies
    private let reactions: Reactions
    private let profile: UserProfile

    private let createTripButton = UIBarButtonItem(image: UIImage(asset: Asset.add), style: .plain)
    private let printButton = UIBarButtonItem(image: UIImage(asset: Asset.print), style: .plain)

    private let searchController = UISearchController(searchResultsController: nil)
    private let searchBarWrapper: SearchBarWrapperView

    private let logout = UIBarButtonItem(title: L10n.Auth.logout, style: .plain)

    init(dependencies: Dependencies, reactions: Reactions, profile: UserProfile) {
        self.dependencies = dependencies
        self.reactions = reactions
        self.profile = profile
        self.searchBarWrapper = SearchBarWrapperView(searchBar: searchController.searchBar)

        super.init(title: L10n.Trip.List.title)

        if reactions.loggedOut != nil {
            navigationItem.leftBarButtonItem = logout
        }

        navigationItem.rightBarButtonItems = [createTripButton, printButton]

        rootView.componentState = .loading

        tabBarItem = UITabBarItem(title: L10n.Trip.List.tabTitle,
                                  image: UIImage(asset: Asset.trips),
                                  selectedImage: UIImage(asset: Asset.tripsSelected))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.searchBar.barTintColor = Colors.accent
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintColor = .white
        searchController.searchBar.isTranslucent = false

        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true

        rootView.headerView = searchBarWrapper

        createTripButton.accessibilityLabel = L10n.Trip.List.create
        printButton.accessibilityLabel = L10n.Trip.List.print
    }

    override func afterInit() {
        let searchQuery = Observable.from([searchController.searchBar.rx.text.asObservable(),
                                           searchController.rx.willDismiss.rewrite(with: "")]).merge()

        let trips = Observable.combineLatest(
            dependencies.tripService.trips(profile: profile),
            searchQuery,
            searchBarWrapper.scopeSelected) { trips, query, scope -> [Trip] in
                let scopedTrips = trips.filter(scope.includeTrip)
                guard (query?.isNotEmpty)! else { return scopedTrips }
                return SearchUtils.searchTrips(trips: scopedTrips, query: query!)
            }
            .shareReplay(1)

        trips.map { $0.isNotEmpty ? .items($0) : .empty(message: L10n.Trip.List.empty) }
            .subscribe(onNext: rootView.setComponentState)
            .addDisposableTo(lifetimeDisposeBag)

        trips.map { $0.isNotEmpty }.subscribe(printButton.rx.isEnabled).addDisposableTo(lifetimeDisposeBag)

        printButton.rx.tap
            .withLatestFrom(trips)
            .map(PrintUtils.printableIntervals)
            .flatMapLatest { [reactions] in
                reactions.selectPrintInterval($0)
            }
            .map(PrintUtils.printableHtml)
            .flatMapLatest(reactions.printItinerary)
            .subscribe()
            .addDisposableTo(lifetimeDisposeBag)

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

        createTripButton.rx.tap
            .flatMapLatest(reactions.createTrip)
            .subscribe()
            .addDisposableTo(lifetimeDisposeBag)

//        rootView.tableView.rx.setDelegate(self).addDisposableTo(lifetimeDisposeBag)
    }

    override func update() {
        navigationController?.navigationBar.apply(style: CommonStyles.blueNavigationbar)
    }

    override func act(on action: TripTableRootView.ActionType) {
        switch action {
        case .selected(let trip):
            reactions.openTrip(trip)
        case .refresh, .rowAction:
            break
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Ensure minimum contentSize, otherwise search header will be jumping up and down
        // Minimum contentSize is the space between navBar and tabBar + height of searchBar (so it can be hidden)
        rootView.tableView.minimumContentSize.height = view.bounds.height - topLayoutGuide.length -
            bottomLayoutGuide.length + searchBarWrapper.searchBarBottom - rootView.tableView.contentInset.top -
            rootView.tableView.contentInset.bottom
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Update the target offset so that the `searchBar` and `scopeBar` are always visible or not at all.
        let targetY = targetContentOffset.pointee.y

        if targetY < searchBarWrapper.searchBarCenterVertical {
            targetContentOffset.pointee.y = searchBarWrapper.searchBarTop
        } else if targetY < searchBarWrapper.searchBarBottom || targetY < searchBarWrapper.scopeBarCenterVertical {
            targetContentOffset.pointee.y = searchBarWrapper.searchBarBottom
        } else if targetY < searchBarWrapper.scopeBarBottom {
            targetContentOffset.pointee.y = searchBarWrapper.scopeBarBottom
        }
    }
}
