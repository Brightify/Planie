//
//  RegistrationRootView.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

import Material
import RxSwift

enum RegistrationAction {
    case signUp(email: String, password: String)
}

final class RegistrationRootView: ViewBase<Void, RegistrationAction> {
    
    override var actions: [Observable<RegistrationAction>] {
        return [
            signUp.rx.tap.withLatestFrom(
                Observable.combineLatest(email.rx.text.replaceNilWith(""), password.rx.text.replaceNilWith(""), resultSelector: RegistrationAction.signUp)
            )
        ]
    }

    let backgroundImage = UIImageView(image: UIImage(asset: Asset.blurredSplash))
    let logo = UIImageView(image: UIImage(asset: Asset.planieLogo))
    let centeringContainer = ContainerView()
    let emailBackground = UIVisualEffectView(effect:  UIBlurEffect(style: .light))
        .styled(using: Styles.fieldBackground)
    let email = UITextField().styled(using: Styles.field, Styles.email)
    let passwordBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        .styled(using: Styles.fieldBackground)
    let password = UITextField().styled(using: Styles.field, Styles.password)
    let signUp = FlatButton(title: L10n.Auth.signUp.uppercased())
        .styled(using: Styles.button, Styles.signUp)

    override func update() {

    }
}

extension RegistrationRootView {
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
        
        static func signUp(button: Button) {
            button.backgroundColor = Color.lightGreen.base
        }
    }
}
