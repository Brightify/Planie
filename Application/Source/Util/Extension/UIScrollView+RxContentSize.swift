//
//  UITableView+RxContentSize.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 10/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reactant

fileprivate class Box<T> {
    
    fileprivate let value: T

    fileprivate init(_ value: T) {
        self.value = value
    }
}

extension UITableView {
    private struct AssociationKeys {
        static var minimumContentSize: UInt8 = 0
    }

    public var minimumContentSize: CGSize {
        get {
            return associatedObject(self, key: &AssociationKeys.minimumContentSize) {
                return Box<CGSize>(CGSize.zero)
            }.value
        }
        set {
            associateObject(self, key: &AssociationKeys.minimumContentSize, value: Box(newValue))
            UITableView.ensureMinimumContentSize(minimumSize: newValue, contentSize: &contentSize)
        }
    }

    open override var contentSize: CGSize {
        get {
            return super.contentSize
        }
        set {
            var newSize = newValue
            UITableView.ensureMinimumContentSize(minimumSize: minimumContentSize, contentSize: &newSize)
            super.contentSize = newSize
        }
    }

    private static func ensureMinimumContentSize(minimumSize: CGSize, contentSize: inout CGSize) {
        var size = contentSize
        if minimumSize.width >= 0 && size.width < minimumSize.width {
            size.width = minimumSize.width
        }
        if minimumSize.height >= 0 && size.height < minimumSize.height {
            size.height = minimumSize.height
        }
        if size != contentSize {
            contentSize = size
        }
    }
}
