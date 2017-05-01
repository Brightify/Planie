//
//  GeoNamesService.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Fetcher
import RxSwift
import Reactant

private struct Endpoints: EndpointProvider {
    static func searchCities(named: String) -> GET<Void, GeoNamesSearchBox> {
        return create("http://api.geonames.org/search?name=\(named.urlQuerySafe)&type=json&style=medium&featureClass=P&username=Planie&inclBbox=true")
    }
}

final class GeoNamesService {
    
    private let fetcher = Fetcher(requestPerformer: AlamofireRequestPerformer())

    init() {
        fetcher.register(requestEnhancers: RequestLogger(defaultOptions: RequestLogging.all))
    }

    func searchCities(name: String) -> Observable<[City]> {
        return fetcher.rx.request(Endpoints.searchCities(named: name))
            .asResult()
            .mapValue { $0.cities }
            .recover([])
    }
}
