//
//  Unit.swift
//  Hydrate
//
//  Created by David Wright on 3/6/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import Foundation

enum Unit: Int, CaseIterable, CustomStringConvertible {
    case milliliters
    case fluidOunces
    case cups
    
    var description: String {
        switch self {
        case .milliliters: return "milliliters (mL)"
        case .fluidOunces: return "fluid ounces (fl oz US)"
        case .cups: return "cups (US)"
        }
    }
    
    var abbreviation: String {
        switch self {
        case .milliliters: return "mL"
        case .fluidOunces: return "oz"
        case .cups: return "cups"
        }
    }
    
    var abbreviationFull: String {
        switch self {
        case .fluidOunces: return "fl oz (US)"
        case .cups: return "cups (US)"
        default: return abbreviation
        }
    }
    
    var conversionFactor: Double {
        switch self {
        case .milliliters: return 1.0
        case .fluidOunces: return 0.033814
        case .cups: return 0.00422675
        }
    }
}
