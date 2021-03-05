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
        if self == floor(self) {
            return String(format: "%.0f", self)
        } else {
            return String(format: "%.1f", self)
        }
    }
}
