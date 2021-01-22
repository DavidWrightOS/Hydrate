//
//  UIViewController+SimpleAlert.swift
//  Hydrate
//
//  Created by David Wright on 1/21/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentSimpleAlert(with title: String?,
                            message: String?,
                            preferredStyle: UIAlertController.Style,
                            dismissText: String,
                            completionUponDismissal: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let dismissAction = UIAlertAction(title: dismissText, style: .cancel, handler: completionUponDismissal)
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
}
