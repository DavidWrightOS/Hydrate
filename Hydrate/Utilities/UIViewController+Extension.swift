//
//  UIViewController+Extension.swift
//  Hydrate
//
//  Created by David Wright on 1/21/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import UIKit

extension UIViewController {
    
    enum AlertOption {
        case destructiveAction, isCancellable
    }
    
    func presentAlert(title: String?,
                      message: String?,
                      actionButtonText: String,
                      preferredStyle: UIAlertController.Style = .alert,
                      options: [AlertOption] = [],
                      actionButtonCompletionHandler: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.view.tintColor = .actionColorHighContrast
        
        if options.contains(.isCancellable) {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancelAction)
        }
        
        let style: UIAlertAction.Style = options.contains(.destructiveAction) ? .destructive : .default
        let primaryAction = UIAlertAction(title: actionButtonText, style: style, handler: actionButtonCompletionHandler)
        alert.addAction(primaryAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentSimpleAlert(title: String?,
                            message: String?,
                            actionButtonText: String = "Dismiss",
                            preferredStyle: UIAlertController.Style = .alert,
                            actionButtonCompletionHandler: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.view.tintColor = .actionColorHighContrast
        
        let dismissAction = UIAlertAction(title: actionButtonText, style: .cancel, handler: actionButtonCompletionHandler)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
}
