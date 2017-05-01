//
//  UIButton+BackgroundColor.swift
//  TravelPlanner
//
//  Created by Matouš Hýbl on 18/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit

extension UIButton {

    @objc(setBackgroundColor:forState:)
    public func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        let rectangle = CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rectangle.size)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rectangle)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        setBackgroundImage(image!, for: state)
    }
}
