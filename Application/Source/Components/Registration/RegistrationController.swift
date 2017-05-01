//
//  RegistrationController.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import IQKeyboardManagerSwift

final class RegistrationController: ControllerBase<Void, RegistrationRootView> {
    struct Dependencies {
        let credentialAuthProvider: CredentialAuthProvider
    }
    struct Reactions {
        let registrationSuccessful: (UserProfile) -> Void
    }
    private let dependencies: Dependencies
    private let reactions: Reactions

    init(dependencies: Dependencies, reactions: Reactions) {
        self.dependencies = dependencies
        self.reactions = reactions

        super.init()
    }

    override func update() {
        navigationController?.navigationBar.apply(style: CommonStyles.clearNavigationBar)
        navigationController?.navigationBar.barStyle = .black
    }

    override func act(on action: RegistrationAction) {
        switch action {
        case .signUp(let email, let password):
            let validatedCredentials = registrationCredentialsRule.run((email: email, password: password))

            switch validatedCredentials {
            case .success(let email, let password):
                IQKeyboardManager.sharedManager().resignFirstResponder()
                let register = dependencies.credentialAuthProvider.register(email: email, password: password)
                    .trackActivity(in: loadingIndicator)
                    .shareReplay(1)

                register.filterError()
                    .subscribe(onNext: reactions.registrationSuccessful)
                    .addDisposableTo(lifetimeDisposeBag)

                register.errorOnly()
                    .map { error in
                        switch error {
                        case .invalidEmail:
                            return L10n.Auth.Error.invalidEmail
                        case .emailAlreadyInUse:
                            return L10n.Auth.Error.emailAlreadyInUse
                        case .weakPassword(let reason):
                            return reason
                        default:
                            return L10n.Auth.Error.unknown
                        }
                    }
                    .subscribe(onNext: {
                        _ = errorAlert(title: L10n.Auth.Error.signupTitle, subTitle: $0)
                    })
                    .addDisposableTo(lifetimeDisposeBag)

            case .failure(let error):
                let errorMessage: String
                switch error {
                case .emailInvalid(.empty):
                    errorMessage = L10n.Auth.Error.emptyEmail
                case .emailInvalid(.invalid):
                    errorMessage = L10n.Auth.Error.invalidEmail
                case .passwordEmpty:
                    errorMessage = L10n.Auth.Error.emptyPassword
                case .passwordTooShort(let minLength):
                    errorMessage = L10n.Auth.Error.shortPassword(minLength)
                }
                _ = errorAlert(title: L10n.Auth.Error.signupTitle, subTitle: errorMessage)
            }
        }
    }
}
