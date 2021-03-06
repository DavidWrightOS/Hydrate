//
//  Format.swift
//  Hydrate
//
//  Created by David Wright on 3/5/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import Foundation

class Format {
    static let numberFormatterRoundingToOneDecimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    static let numberFormatterRoundingToZeroDecimals: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}
