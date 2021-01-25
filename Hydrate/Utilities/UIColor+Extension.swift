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
    
    // Current Theme
    static let currColor1 = #colorLiteral(red: 0.2117647059, green: 0.2431372549, blue: 0.337254902, alpha: 1)
    static let currColor2 = #colorLiteral(red: 0.2941176471, green: 0.5411764706, blue: 0.6117647059, alpha: 1)
    static let currColor3 = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
    static let actionColor = #colorLiteral(red: 0.2941176471, green: 0.5411764706, blue: 0.6117647059, alpha: 1)
    
    // Test Colors
    static let testColor1 = #colorLiteral(red: 0.09147954031, green: 0.2418307391, blue: 0.3917707695, alpha: 1)
    static let testColor2 = #colorLiteral(red: 0.02172357589, green: 0.3989364803, blue: 0.7827919722, alpha: 1)
    static let testColor3 = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    static let testColor4 = #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)
    static let testColor5 = #colorLiteral(red: 0.000614751596, green: 0.4955587983, blue: 0.6541782022, alpha: 1)
    static let testColor6 = #colorLiteral(red: 0.01967617683, green: 0.5008978248, blue: 0.5656463504, alpha: 1)
    static let testColor7 = #colorLiteral(red: 0.6647506356, green: 0.6750287414, blue: 0.6616437435, alpha: 1)
    static let testColor8 = #colorLiteral(red: 0.6548998952, green: 0.6548389792, blue: 0.6634429097, alpha: 1)
    static let testColor9 = #colorLiteral(red: 0.7499628663, green: 0.7656405568, blue: 0.7302817702, alpha: 1)
    static let testColor0 = #colorLiteral(red: 0.7533128858, green: 0.8374676108, blue: 0.8750609756, alpha: 1)
    
    // ConfettiColors
    static let confettiColors = [UIColor(hex: 0x0058d0),
                                 UIColor(hex: 0x2D7FC1),
                                 UIColor(hex: 0x1C86CF),
                                 UIColor(hex: 0x0A84FF),
                                 UIColor(hex: 0x38D1FE),
                                 UIColor(hex: 0x5AC8F5),
                                 UIColor(hex: 0x76D6FF),
                                 UIColor(hex: 0xDFDEDB),
                                 UIColor(hex: 0xF3F3F3)]
    
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
