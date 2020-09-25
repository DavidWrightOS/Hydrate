//
//  UIColor+Extension.swift
//  Hydrate
//
//  Created by David Wright on 9/14/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

extension UIColor {
    
    // Setup custom colours we can use throughout the app using hex values
    static let undeadWhite = UIColor(hex: 0xd8d8d8)
    static let undeadWhite65 = UIColor(hex: 0x9FA2AB)
    static let sicklySmurfBlue = UIColor(hex: 0x4b8a9c)
    static let ravenClawBlue = UIColor(hex: 0x363e56)
    static let ravenClawBlue90 = UIColor(hex: 0x4a5167)
    static let ravenClawBlue70 = UIColor(hex: 0x727788)
    static let disabledButtonColor = UIColor(hex: 0x5D5F66)
    
    static let backgroundColor = ravenClawBlue
    static let markerLabelColor = undeadWhite.withAlphaComponent(0.4)
    static let markerLineColor = undeadWhite.withAlphaComponent(0.2)
    static let waterColor = sicklySmurfBlue.withAlphaComponent(0.5)
    static let intakeButtonColor = undeadWhite
    static let intakeButtonTextColor = sicklySmurfBlue
    
    // Create a UIColor from RGB
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
    // Create a UIColor from a hex value (E.g 0x000000)
    convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            a: a
        )
    }
}
