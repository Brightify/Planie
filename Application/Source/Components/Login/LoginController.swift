//
//  LoginController.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 31/08/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import IQKeyboardManagerSwift

final class LoginController: ControllerBase<Void, LoginRootView> {
    struct Dependencies {
        let credentialAuthProvider: CredentialAuthProvider
    }
    struct Reactions {
        let loginSuccessful: (UserProfile) -> Void
        let openRegistration: () -> Void
    }

    private let dependencies: Dependencies
    private let reactions: Reactions

    override var navigationBarHidden: Bool {
        return true
    }
    
    init(dependencies: Dependencies, reactions: Reactions) {
        self.dependencies = dependencies
        self.reactions = reactions

        super.init()
    }

    override func update() {
        navigationController?.navigationBar.apply(style: CommonStyles.clearNavigationBar)
        navigationController?.navigationBar.barStyle = .black
    }

    override func act(on action: LoginAction) {
        switch action {
        case .login(let email, let password):
            let validatedCredentials = loginCredentialsRule.run((email: email, password: password))

            switch validatedCredentials {
            case .success(let email, let password):
                IQKeyboardManager.shared.resignFirstResponder()
                let login = dependencies.credentialAuthProvider.login(email: email, password: password)
                    .trackActivity(in: loadingIndicator)
                    .shareReplay(1)

                login.filterError()
                    .subscribe(onNext: reactions.loginSuccessful)
                    .disposed(by: lifetimeDisposeBag)

                login.errorOnly()
                    .map { error in
                        switch error {
                        case .wrongPassword, .common(.userNotFound):
                            return L10n.Auth.Error.wrongPassword
                        case .userDisabled:
                            return L10n.Auth.Error.userDisabled
                        default:
                            return L10n.Auth.Error.unknown
                        }
                    }
                    .subscribe(onNext: {
                        _ = errorAlert(title: L10n.Auth.Error.loginTitle, subTitle: $0)
                    })
                    .disposed(by: lifetimeDisposeBag)

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
                _ = errorAlert(title: L10n.Auth.Error.loginTitle, subTitle: errorMessage)
            }

        case .signUp:
            reactions.openRegistration()
        }
    }
}
