//
//  UITableView+Extension.swift
//  Hydrate
//
//  Created by David Wright on 2/15/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import UIKit

fileprivate let splashScreenIdentifier = "hydrateSplashScreenIdentifier"

extension UITableView {
    
    func addSplashScreen(title: String? = nil, subtitle: String? = nil, image: UIImage? = nil) {
        
        guard title != nil || subtitle != nil || image != nil else { return }
        
        // Remove the existing splash screen if one exists
        removeSplashScreen()
                
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .undeadWhite60
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = .undeadWhite
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        let imageView = UIImageView()
        
        if let image = image {
            imageView.image = image.withTintColor(.undeadWhite25, renderingMode: .alwaysOriginal)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageSize: CGFloat = 200
            let imageRatio = image.size.height / image.size.width
            
            if imageRatio < 1 {
                imageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: imageRatio).isActive = true
            } else {
                imageView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1/imageRatio).isActive = true
            }
        }
        
        // Create splash screen stackView
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        stackView.accessibilityIdentifier = splashScreenIdentifier
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        addSubview(stackView)
                
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.readableContentGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.readableContentGuide.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    func removeSplashScreen() {
        if let splashView = self.subviews.first(where: { $0.accessibilityIdentifier == splashScreenIdentifier }) {
            splashView.removeFromSuperview()
        }
    }
}
