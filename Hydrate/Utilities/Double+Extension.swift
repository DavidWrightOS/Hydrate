//
//  Double+Extension.swift
//  Hydrate
//
//  Created by David Wright on 3/4/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import Foundation

extension Double {
    var roundedString: String {
        let number = NSNumber(value: self)
        
        if self < 100 {
            return Format.numberFormatterRoundingToOneDecimal.string(from: number)!
        } else {
            return Format.numberFormatterRoundingToZeroDecimals.string(from: number)!
        }
    }
}
