//
//  LocalNotificationContentModel.swift
//  Hydrate
//
//  Created by David Wright on 2/12/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

struct LocalNotificationContentModel {
    let title: String?
    let body: String?
    let badge: Int?
    let hasSound: Bool
    
    init(title: String? = nil, body: String? = nil, badge: Int? = nil, hasSound: Bool = true) {
        self.title = title
        self.body = body
        self.badge = badge
        self.hasSound = hasSound
    }
}
