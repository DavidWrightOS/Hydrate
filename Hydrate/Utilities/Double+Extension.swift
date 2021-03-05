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
        return Format.numberFormatter.string(from: number)!
    }
}
