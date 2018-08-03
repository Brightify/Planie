//
//  ActivityIndicator.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import JGProgressHUD

import SCLAlertView
import Reactant

private let dialogAppearance = SCLAlertView.SCLAppearance(kWindowWidth: UIScreen.main.bounds.width - 40)

func successAlert(title: String, subTitle: String) -> Observable<Void> {
    let view = SCLAlertView(appearance: dialogAppearance)
    return view.showSuccess(title, subTitle: subTitle).dismissed()
}

let successIndicator = AnyObserver<String> { event in
    switch event {
    case .next(let value):
        let hud = JGProgressHUD(style: .extraLight)
        hud?.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud?.textLabel?.text = value
        hud?.backgroundColor = UIColor(white: 0, alpha: 70%)
        hud?.show(in: UIApplication.shared.keyWindow)
        hud?.dismiss(afterDelay: 1)
        hud?.tapOutsideBlock = { hud in
            hud?.dismiss()
        }
    default:
        return
    }
}

func errorAlert(title: String, subTitle: String) -> Observable<Void> {
    let view = SCLAlertView(appearance: dialogAppearance)
    return view.showError(title, subTitle: subTitle).dismissed()
}

let errorIndicator = AnyObserver<String> { event in
    switch event {
    case .next(let value):
        let hud = JGProgressHUD(style: .extraLight)
        hud?.indicatorView = JGProgressHUDErrorIndicatorView()
        hud?.textLabel?.text = value
        hud?.backgroundColor = UIColor(white: 0, alpha: 70%)
        hud?.show(in: UIApplication.shared.keyWindow)
        hud?.dismiss(afterDelay: 5)
        hud?.tapOutsideBlock = { hud in
            hud?.dismiss()
        }
    default:
        return
    }
}

let loadingIndicator: ActivityIndicator<String> = {
    let activityIndicator = ActivityIndicator<String>()
    let hud: JGProgressHUD = JGProgressHUD(style: .extraLight)
    hud.backgroundColor = UIColor.black.fadedOut(by: 30%)
    activityIndicator.asDriver().drive(onNext: { loading, message in
        hud.textLabel?.text = message
        if loading && !hud.isVisible {
            hud.show(in: UIApplication.shared.keyWindow)
        } else if !loading && hud.isVisible {
            hud.dismiss()
        }
        }).disposed(by: activityIndicator.disposeBag)
    
    return activityIndicator
}()

extension SCLAlertViewResponder {
    func dismissed() -> Observable<Void> {
        let subject = PublishSubject<Void>()
        setDismissBlock {
            subject.onLast()
        }
        return subject
    }
}
