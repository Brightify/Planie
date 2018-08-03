//
//  CitySelectionController.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import DataMapper
import RxSwift
import RxCocoa

import IQKeyboardManagerSwift

final class CitySelectionController: ControllerBase<String, CitySelectionRootView> {
    struct Dependencies {
        let geoNamesService: GeoNamesService
    }
    struct Reactions {
        let citySelected: (City) -> Void
        let close: () -> Void
    }
    
    private let searchBox = SearchBox(placeholder: L10n.City.Search.placeholder)

    private let dependencies: Dependencies
    private let reactions: Reactions

    init(dependencies: Dependencies, reactions: Reactions) {
        self.dependencies = dependencies
        self.reactions = reactions

        super.init()
    }

    override func loadView() {
        super.loadView()

        _ = searchBox.becomeFirstResponder()
    }

    override func afterInit() {
        searchBox.observableState
            .filter { $0.characters.count < 2 }
            .subscribe(onNext: { [rootView] _ in
                rootView.componentState = .empty(message: L10n.City.Search.minimumCharacters(2))
            })
            .disposed(by: lifetimeDisposeBag)

        searchBox.observableState
            .filter { $0.characters.count >= 2 }
            .throttle(0.5, scheduler: MainScheduler.instance)
            .do(onNext: { [rootView] _ in rootView.componentState = .loading })
            .flatMapLatest { [dependencies] in dependencies.geoNamesService.searchCities(name: $0) }
            .map { $0.isNotEmpty ? .items($0) : .empty(message: L10n.City.Search.notFound) }
            .subscribe(onNext: rootView.setComponentState)
            .disposed(by: lifetimeDisposeBag)
    }

    override func update() {
        navigationController?.navigationBar.apply(style: CommonStyles.blueNavigationbar)

        searchBox.componentState = componentState
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = searchBox
        searchBox.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(asset: Asset.back), style: .plain) { [reactions] in
            reactions.close()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        IQKeyboardManager.shared.resignFirstResponder()
    }

    override func act(on action: PlainTableViewAction<CityCell>) {
        switch action {
        case .selected(let city):
            reactions.citySelected(city)
        case .refresh, .rowAction:
            break
        }
    }
}
