//
//  CreateTripControllerTest.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Nimble
import XCTest
import Firebase
import SwiftDate
import RxNimble
import Reactant
import Fetcher
import DataMapper

class CreateTripControllerTest: BaseAuthorizedUITestCase {
    
    let fetcher: Fetcher = {
        let fetcher = Fetcher(requestPerformer: AlamofireRequestPerformer())
        fetcher.register(requestEnhancers: RequestLogger(defaultOptions: RequestLogging.all))
        fetcher.register(requestModifiers: BaseUrl(baseUrl: TestConstants.databaseUrl))
        return fetcher
    }()

    override class var authorizeUser: String {
        return TestConstants.validUser
    }

    override func setUp() {
        super.setUp()

        UITestNavigator.LoginController.login(email: TestConstants.validUser, password: TestConstants.password)
    }

    func testCanCreateAndDeleteTrip() {
        let destination = "London"
        let begin = Date() + 1.days
        let end = Date() + 2.days
        let comment = "Hello comment!"

        UITestNavigator.TripTableController
            .createTrip()
            .selectDestination(name: destination)
            .setDate(begin: begin, end: end)
            .set(comment: comment)
            .elements.save.tap()
        waitWhileLoading()

        let user = type(of: self).user
        let tripsEndpoint = GET<Void, SupportedType>("/trips/\(user?.uid).json?auth=\(TestConstants.databaseSecret)")

        let trips = try! fetcher.rx.request(tripsEndpoint)
            .map { $0.result.value }.toBlocking().single()?.flatMap { $0 }
        
        expect(trips?.array?.count) == 1
        let data = DeserializableData(data: trips?.array?.first ?? .null, objectMapper: ObjectMapper())

        let tripDestination: String? = data["destination"]["name"].get()
        let tripBegin: Date? = data["begin"].get(using: ISO8601DateTransformation())
        let tripEnd: Date? = data["end"].get(using: ISO8601DateTransformation())
        let tripComment: String? = data["comment"].get() ?? ""
        
        expect(tripDestination) == destination
        expect(tripBegin?.isInSameDayOf(date: begin)).to(beTrue())
        expect(tripEnd?.isInSameDayOf(date: end)).to(beTrue())
        expect(tripComment) == comment

        let tripDetail = UITestNavigator.TripTableController.openTripDetail(row: 0)

        tripDetail.elements.delete.tap()
        tripDetail.elements.confirmDelete.tap()
        waitWhileLoading()

        let tripsAfterDeleted = try! fetcher.rx.request(tripsEndpoint)
            .map { $0.result.value }.toBlocking().single()?.flatMap { $0 }

        expect(tripsAfterDeleted) == SupportedType.null
    }

    func testCanEditTrip() {
        let oldBegin = ISO8601DateTransformation().transform(from: .string("2016-10-31T16:39:40+01:00"))
        let oldEnd = ISO8601DateTransformation().transform(from: .string("2016-11-01T16:39:40+01:00"))
        let newDestination = "London"
        let newBegin = Date() + 1.months
        let newEnd = Date() + 2.months
        let newComment = "Hello world!"
        let tripData = [
            "begin": "2016-10-31T16:39:40+01:00",
            "comment": "",
            "destination": [
                "adminName1": "Texas",
                "bbox": [
                    "east": -96.63742330665194,
                    "north": 32.92511539940531,
                    "south": 32.64099580059468,
                    "west": -96.97591009334805
                ],
                "countryName": "United States",
                "lat": 32.78306,
                "lng": -96.80667,
                "name": "Dallas"
            ],
            "end": "2016-11-01T16:39:40+01:00",
            "id": "-KR9EPfqAjbjrY-pJ19D"
        ] as [String : Any]

        let user = type(of: self).user
        let tripPath = "/trips/\(user?.uid)/\(tripData["id"]!).json?auth=\(TestConstants.databaseSecret)"
        let createTripEndpoint = PUT<SupportedType, Void>(tripPath)
        let tripsEndpoint = GET<Void, SupportedType>(tripPath)
        let deleteTripEndpoint = DELETE<Void, Void>(tripPath)

        _ = try! fetcher.rx.request(createTripEndpoint, input: JsonSerializer().typedDeserialize(tripData)).toBlocking().single()
        defer { _ = try! fetcher.rx.request(deleteTripEndpoint).toBlocking().single() }

        UITestNavigator.TripTableController.openTripDetail(row: 0).elements.edit.tap()

        UITestNavigator.CreateTripController
            .selectDestination(name: newDestination)
            .setDate(begin: newBegin, fromBegin: oldBegin, end: newEnd, fromEnd: oldEnd)
            .set(comment: newComment)
            .elements.save.tap()
        waitWhileLoading()

        let trips = try! fetcher.rx.request(tripsEndpoint)
            .map { $0.result.value }.toBlocking().single()?.flatMap { $0 }
        
        expect(trips?.array?.count) == 1
        let data = DeserializableData(data: trips?.array?.first ?? .null, objectMapper: ObjectMapper())
        
        let tripDestination: String? = data["destination"]["name"].get()
        let tripBegin: Date? = data["begin"].get(using: ISO8601DateTransformation())
        let tripEnd: Date? = data["end"].get(using: ISO8601DateTransformation())
        let tripComment: String? = data["comment"].get() ?? ""
        
        expect(tripDestination) == newDestination
        expect(tripBegin?.isInSameDayOf(date: newBegin)).to(beTrue())
        expect(tripEnd?.isInSameDayOf(date: newEnd)).to(beTrue())
        expect(tripComment) == newComment
    }
}
