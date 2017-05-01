//
//  MainWireframe.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 31/08/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import Reactant
import RxSwift
import Lipstick

final class MainWireframe: Wireframe {
    
    private let module: DependencyModule

    init(module: DependencyModule) {
        self.module = module
    }

    func entrypoint() -> UIViewController {
        let navigationController = UINavigationController()

        navigationController.push(controller: initialController())

        return navigationController
    }
    
    func initialController() -> InitialController {
        return create { provider in
            let dependencies = InitialController.Dependencies(authManager: module.authManager)
            let reactions = InitialController.Reactions(
                initComplete: { profile in
                    if let profile = profile {
                        provider.navigation?.replaceAll(with: self.authorizedSection(profile: profile))
                    } else {
                        provider.navigation?.replaceAll(with: self.loginController())
                    }
                })

            return InitialController(dependencies: dependencies, reactions: reactions)
        }
    }

    func loginController() -> LoginController {
        return create { provider in
            let dependencies = LoginController.Dependencies(credentialAuthProvider: module.credentialAuthProvider)
            let reactions = LoginController.Reactions(
                loginSuccessful: { profile in
                    provider.navigation?.replaceAll(with: self.authorizedSection(profile: profile))
                },
                openRegistration: {
                    provider.navigation?.push(controller: self.registrationController())
                })

            return LoginController(dependencies: dependencies, reactions: reactions)
        }
    }

    func registrationController() -> RegistrationController {
        return create { provider in
            let dependencies = RegistrationController.Dependencies(credentialAuthProvider: module.credentialAuthProvider)
            let reactions = RegistrationController.Reactions(
                registrationSuccessful: { profile in
                    provider.navigation?.replaceAll(with: self.authorizedSection(profile: profile))
                })

            return RegistrationController(dependencies: dependencies, reactions: reactions)
        }
    }

    func citySelection(close: @escaping () -> Void) -> (controller: CitySelectionController, citySelected: Observable<City>) {
        let citySelected = PublishSubject<City>()
        return (create { provider in
            let dependencies = CitySelectionController.Dependencies(geoNamesService: module.geoNamesService)
            let reactions = CitySelectionController.Reactions(
                citySelected: { city in
                    citySelected.onNext(city)
                },
                close: close)
            return CitySelectionController(dependencies: dependencies, reactions: reactions)
        }, citySelected)
    }

    func authorizedSection(profile: UserProfile) -> UIViewController {
        return create { provider in
            let loggedOut: () -> Void = {
                provider.navigation?.popAllAndReplace(with: self.loginController())
            }
            if profile.role == .user {
                return trips(profile: profile, loggedOut: loggedOut)
            } else {
                let controllers: [UIViewController] = [
                    self.trips(profile: profile, loggedOut: loggedOut),
                    self.users(profile: profile, loggedOut: loggedOut)]

                let navigationControllers = controllers.map { controller -> UIViewController in
                    let navigationController = UINavigationController()
                    navigationController.push(controller: controller)
                    return navigationController
                }

                return AdministrationTabBarController(controllers: navigationControllers)
            }
        }
    }

    func trips(profile: UserProfile, loggedOut: (() -> Void)? = nil) -> TripTableController {
        return create { provider in
            let dependencies = TripTableController.Dependencies(
                tripService: module.tripService,
                authManager: module.authManager)
            let reactions = TripTableController.Reactions(
                createTrip: {
                    let navigationController = UINavigationController()
                    let (tripController, tripSaved) = self.createTrip(profile: profile, mode: .create, close: { provider.navigation?.dismiss() })
                    tripController.componentState = Trip()
                    tripController.navigationItem.leftBarButtonItem =
                        UIBarButtonItem(title: L10n.Common.cancel, style: .plain) { _ in
                            navigationController.dismiss()
                    }
                    navigationController.push(controller: tripController)
                    provider.navigation?.present(navigationController, animated: true)
                    return tripSaved.do(onNext: { _ in provider.navigation?.dismiss() })
                },
                openTrip: { trip in
                    provider.navigation?.push(controller: self.tripDetail(profile: profile).with(state: trip))
                },
                loggedOut: loggedOut,
                selectPrintInterval: { from in
                    provider.navigation.map { self.presentPrintIntervalSelection(in: $0, selectFrom: from) } ?? .empty()
                },
                printItinerary: printHtml,
                confirmDestruction: { action in
                    provider.navigation.map { self.presentDestructionConfirmationAlert(in: $0, action: action) } ?? .empty()
                })
            return TripTableController(dependencies: dependencies, reactions: reactions, profile: profile)
        }
    }

    func createTrip(profile: UserProfile, mode: CreateTripControllerMode, close: @escaping () -> Void) -> (controller: CreateTripController, tripSaved: Observable<Trip>) {
        let tripSaved = PublishSubject<Trip>()
        return (create { provider in
            let dependencies = CreateTripController.Dependencies(tripService: module.tripService)
            let reactions = CreateTripController.Reactions(
                selectCity: { query in
                    let (controller, citySelected) = self.citySelection(close: { provider.navigation?.pop() })
                    controller.componentState = query
                    provider.navigation?.push(controller: controller)
                    return citySelected.do(onNext: { _ in provider.navigation?.pop() })
                },
                close: close,
                tripSaved: { trip in
                    tripSaved.onNext(trip)
                })
            return CreateTripController(dependencies: dependencies,
                                        reactions: reactions,
                                        profile: profile,
                                        mode: mode)
        }, tripSaved)
    }

    func tripDetail(profile: UserProfile) -> TripDetailController {
        return create { provider in
            let dependencies = TripDetailController.Dependencies(tripService: module.tripService)
            let reactions = TripDetailController.Reactions(
                editTrip: { trip in
                    let navigationController = UINavigationController()
                    let (tripController, tripSaved) = self.createTrip(profile: profile, mode: .edit, close: { provider.navigation?.dismiss() })
                    tripController.componentState = trip
                    tripController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain) { _ in
                        navigationController.dismiss()
                    }
                    navigationController.push(controller: tripController)
                    provider.navigation?.present(navigationController, animated: true)
                    return tripSaved.do(onNext: { _ in provider.navigation?.dismiss() })
                },
                close: { provider.navigation?.pop() },
                confirmDestruction: { action in
                    provider.navigation.map { self.presentDestructionConfirmationAlert(in: $0, action: action) } ?? .empty()
                })
            return TripDetailController(dependencies: dependencies, reactions: reactions, profile: profile)
        }
    }

    func users(profile: UserProfile, loggedOut: (() -> Void)?) -> UserTableController {
        return create { provider in
            let dependencies = UserTableController.Dependencies(
                userService: module.userService,
                authManager: module.authManager
            )

            let reactions = UserTableController.Reactions(
                openUser: { selectedProfile in
                    provider.navigation?.push(controller: self.userProfile(loggedInProfile: profile, shownProfile: selectedProfile))
                },
                loggedOut: loggedOut,
                confirmDestruction: { action in
                    provider.navigation.map { self.presentDestructionConfirmationAlert(in: $0, action: action) } ?? .empty()
                })
            return UserTableController(dependencies: dependencies, reactions: reactions, loggedInUser: profile)
        }
    }

    func userProfile(loggedInProfile: UserProfile, shownProfile: UserProfile) -> UserDetailController {
        return create { provider in
            let dependencies = UserDetailController.Dependencies(userService: module.userService)
            let reactions = UserDetailController.Reactions(
                openTrips: { profile in
                    provider.navigation?.push(controller: self.trips(profile: profile))
                },
                selectRole: { currentRole in
                    provider.navigation.map(self.presentRoleSelection) ?? .empty()
                })

            return UserDetailController(dependencies: dependencies,
                                        reactions: reactions,
                                        loggedInUser: loggedInProfile,
                                        shownProfile: shownProfile)
        }
    }
    
    func presentRoleSelection(in navigation: UINavigationController) -> Observable<Role> {
        let selected = PublishSubject<Role>()
        let alertController = UIAlertController(title: L10n.User.Detail.selectRole, message: nil, preferredStyle: .actionSheet)

        let actions = Role.allRoles.map { role in
            UIAlertAction(title: role.localizedName, style: .default) { _ in selected.onLast(role) }
        }
        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .cancel) { _ in
            selected.onCompleted()
        }

        actions.forEach(alertController.addAction)
        alertController.addAction(cancelAction)

        navigation.present(alertController, animated: true)

        return selected
    }

    func presentPrintIntervalSelection(in navigation: UINavigationController,
                                       selectFrom: [PrintUtils.IntervalWithTrips]) -> Observable<PrintUtils.IntervalWithTrips>
    {
        let selected = PublishSubject<PrintUtils.IntervalWithTrips>()
        let alertController = UIAlertController(title: L10n.Trip.Print.selectInterval,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        let actions = selectFrom.map { interval, trips in
            UIAlertAction(title: interval.localizedDescription + " (\(trips.count))", style: .default) { _ in
                selected.onLast((interval: interval, trips: trips))
            }
        }
        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .cancel) { _ in
            selected.onCompleted()
        }
        actions.forEach(alertController.addAction)
        alertController.addAction(cancelAction)

        navigation.present(alertController, animated: true)

        return selected
    }


    /// Presents a print controller allowing user to print the supplied `html`.
    func printHtml(html: String) -> Observable<Void> {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .grayscale

        let formatter = UIMarkupTextPrintFormatter(markupText: html)
        formatter.perPageContentInsets = UIEdgeInsets(8)

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printFormatter = formatter

        let subject = PublishSubject<Void>()
        printController.present(animated: true) { controller, completed, error in
            subject.onLast()
        }
        return subject
    }

    /** 
     Presents an alert with cancel and destructive buttons for the given action.
     
     If `cancel` is selected, the observable sequence is completed. If `destroy` is selected, the observable sequence
     receives single .Next event and then completes.
     
     Usage: Return from `flatMapLatest` before the guarded action.
     */
    func presentDestructionConfirmationAlert(in navigation: UINavigationController, action: DestructiveAction) -> Observable<Void> {
        let alertController = UIAlertController(title: action.title, message: action.message, preferredStyle: .alert)
        let resultSubject = PublishSubject<Void>()
        
        let cancelAction = UIAlertAction(title: action.cancelTitle, style: .cancel) { _ in
            resultSubject.onCompleted()
        }
        alertController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: action.destroyTitle, style: .destructive) { _ in
            resultSubject.onLast()
        }
        alertController.addAction(destroyAction)

        navigation.present(alertController, animated: true)

        return resultSubject
    }
}
