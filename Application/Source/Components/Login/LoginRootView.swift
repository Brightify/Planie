//
//  LoginRootView.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import Lipstick
import Material
import RxSwift

enum LoginAction {
    case login(email: String, password: String)
    case signUp
}

final class LoginRootView: ViewBase<Void, LoginAction> {

    override var actions: [Observable<LoginAction>] {
        return [
            logIn.rx.tap.withLatestFrom(
                Observable.combineLatest(email.rx.text.replaceNilWith(""), password.rx.text.replaceNilWith(""), resultSelector: LoginAction.login)
            ),
            signUp.rx.tap.rewrite(with: LoginAction.signUp)
        ]
    }

    internal let blurredBackgroundImage = UIImageView(image: UIImage(asset: Asset.blurredSplash))
    internal let centeringContainer = UIView()
    internal let emailBackground = UIVisualEffectView(effect:  UIBlurEffect(style: .light))
        .styled(using: Styles.fieldBackground)
    internal let email = UITextField().styled(using: Styles.field, Styles.email)
    internal let passwordBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        .styled(using: Styles.fieldBackground)
    internal let password = UITextField().styled(using: Styles.field, Styles.password)
    internal let logIn = FlatButton(title: L10n.Auth.login.uppercased()).styled(using: Styles.button, Styles.signIn)
    internal let signUp = FlatButton(title: L10n.Auth.signUp.uppercased())
        .styled(using: Styles.button, Styles.newAccount)

    override func update() {
    }

    override func loadView() {
        super.loadView()
        email.leftView = UIView(frame: CGRect(width: 8))
        email.leftViewMode = .always

        password.leftView = UIView(frame: CGRect(width: 8))
        password.leftViewMode = .always

        blurredBackgroundImage.alpha = 0
        centeringContainer.alpha = 0
        UIView.animate(withDuration: 0.5,
                                   delay: 0,
                                   options: .curveEaseInOut,
                                   animations: { [centeringContainer, blurredBackgroundImage] in
                                    centeringContainer.alpha = 1
                                    blurredBackgroundImage.alpha = 1
            },
                                   completion: nil)
    }
}

extension LoginRootView {
    fileprivate struct Styles {
        static func fieldBackground(view: UIVisualEffectView) {
            view.layer.cornerRadius = 4
            view.clipsToBounds = true
        }

        static func field(textField: UITextField) {
            textField.textColor = .white
            textField.tintColor = .white
        }

        static func email(textField: UITextField) {
            textField.attributedPlaceholder = L10n.Auth.email.attributed(.foregroundColor(.white))
            textField.keyboardType = .emailAddress
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }

        static func password(textField: UITextField) {
            textField.attributedPlaceholder = L10n.Auth.password.attributed(.foregroundColor(.white))
            textField.isSecureTextEntry = true
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }

        static func button(button: Button) {
            button.titleLabel?.font = Fonts.displayLight(size: 14)
        }

        static func signIn(button: Button) {
            button.backgroundColor = Color.lightGreen.base
        }

        static func newAccount(button: Button) {
            button.backgroundColor = Color.blue.base
        }
    }
}
