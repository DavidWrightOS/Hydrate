//
//  LocalNotificationManager.swift
//  Hydrate
//
//  Created by David Wright on 2/11/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import UserNotifications

class LocalNotificationManager: NSObject {
    
    // MARK: - Properties
    
    var authorized = false
    private var pending: [UNNotificationRequest] = []
    private var delivered: [UNNotification] = []
    
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        center.delegate = self
    }
    
    // MARK: - Public Methods
    
    func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        center.requestAuthorization(options: [.sound, .alert]) { [weak self] granted, error in
            
            if let error = error {
                NSLog("Error requesting local notification authorization: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                self?.authorized = granted
                completion(granted)
            }
        }
    }
    
    func refreshNotifications() {
        center.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.pending = requests
            }
        }
        
        center.getDeliveredNotifications { delivered in
            DispatchQueue.main.async {
                self.delivered = delivered
            }
        }
    }
    
    func removePendingNotifications(identifiers: [String]) {
        print("Removing \(identifiers.count) of \(pending.count) total pending notifications...")
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        refreshNotifications()
    }
    
    func removeAllPendingNotifications() {
        print("Removing all \(pending.count) pending notifications...")
        center.removeAllPendingNotificationRequests()
        refreshNotifications()
    }
    
    func removeDeliveredNotifications(identifiers: [String]) {
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
        refreshNotifications()
    }
    
    func scheduleNotification(trigger: UNNotificationTrigger, content contentModel: LocalNotificationContentModel, onError: @escaping (String) -> Void) {
        
        let content = UNMutableNotificationContent()
        let identifier = UUID().uuidString
        
        if let title = contentModel.title {
            content.title = title
        }
        
        if let body = contentModel.body {
            content.body = body
        }
        
        if contentModel.hasSound {
            content.sound = .default
        }
        
        if let badge = contentModel.badge {
            content.badge = NSNumber(value: badge)
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { [weak self] error in
            
            if let error = error {
                DispatchQueue.main.async {
                    onError(error.localizedDescription)
                }
                return
            }
            
            self?.refreshNotifications()
        }
    }
}

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert])
    }
}

