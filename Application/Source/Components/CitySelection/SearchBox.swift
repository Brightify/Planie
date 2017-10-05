//
//  SearchBox.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

final class SearchBox: ViewBase<String, Void> {
    let textField = TextField()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: 28)
    }

    init(placeholder: String? = nil) {
        super.init()

        textField.placeholder = placeholder
    }

    override func afterInit() {
        textField.rx.text.filterNil().skip(1)
            .subscribe(onNext: { [weak self] in
                self?.componentState = $0
            })
            .addDisposableTo(lifetimeDisposeBag)
    }

    override func update() {
        textField.rx.text.onNext(componentState)
    }

    override func loadView() {
        apply(style: Styles.base)
        translatesAutoresizingMaskIntoConstraints = true
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 28)
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}

extension SearchBox.Styles {
    static func base(searchBox: SearchBox) {
        searchBox.backgroundColor = .white
        searchBox.layer.borderWidth = 0
        searchBox.layer.cornerRadius = 4
    }
}
