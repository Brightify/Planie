//
//  SearchBox.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 04/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant


final class SearchBox: ViewBase<String, Void> {
    
    private let icon = UIImageView(image: UIImage(asset: Asset.search))
    private let textField = UITextField().styled(using: Styles.textField)

    init(placeholder: String? = nil) {
        super.init()

        textField.placeholder = placeholder
    }

    override func update() {
        textField.rx.text.onNext(componentState)

        textField.rx.text.filterNil().skip(1)
            .subscribe(onNext: { [weak self] in
                self?.componentState = $0
            })
            .addDisposableTo(stateDisposeBag)
    }

    override func loadView() {
        children(
            icon,
            textField
        )

        apply(style: Styles.base)

        translatesAutoresizingMaskIntoConstraints = true
    }

    override func setupConstraints() {
        icon.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(12)
        }

        textField.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(12)
            make.trailing.equalTo(-4)

            make.centerY.equalToSuperview()
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 28)
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}

extension SearchBox {
    fileprivate struct Styles {
        static func base(searchBox: SearchBox) {
            searchBox.backgroundColor = .white
            searchBox.layer.borderWidth = 0
            searchBox.layer.cornerRadius = 4
        }

        static func textField(textField: UITextField) {
            textField.clearButtonMode = UITextFieldViewMode.whileEditing
            textField.font = Fonts.displayRegular(size: 14)
            textField.tintColor = Colors.accent
        }
    }
}
