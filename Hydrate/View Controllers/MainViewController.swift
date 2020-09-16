//
//  MainViewController.swift
//  Hydrate
//
//  Created by David Wright on 9/14/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    var totalIntake: Int = 0 {
        didSet {
            waterView.waterLevelHeight = waterLevel
            updateViews()
        }
    }
    
    var targetDailyIntake: Int = 96
    
    var waterLevel: CGFloat {
        CGFloat(totalIntake) / CGFloat(targetDailyIntake) * ((view.bounds.maxY - measurementMarkersView.frame.minY) / view.bounds.maxY)
    }
    
    //MARK: - UI Components
    
    fileprivate var waterView: WaterAnimationView!
    
    fileprivate let addWaterIntakeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "water-button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate let showHistoryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendar-button"), for: .normal)
        button.tintColor = UIColor.undeadWhite
        button.contentHorizontalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0);
        button.addTarget(self, action: #selector(handleShowHistoryTapped), for: .touchUpInside)
        return button
    }()
    
    fileprivate let showSettingsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "settings-button"), for: .normal)
        button.tintColor = UIColor.undeadWhite
        button.contentHorizontalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0);
        button.addTarget(self, action: #selector(handleShowSettingsTapped), for: .touchUpInside)
        return button
    }()
    
    fileprivate let intakeAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 oz."
        label.textAlignment = .center
        label.textColor = .undeadWhite
        label.font = UIFont.boldSystemFont(ofSize: 52)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let topControlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .top
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    fileprivate let measurementMarkersView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    //MARK: - Private
    
    fileprivate func setupViews() {
        view.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.2431372549, blue: 0.337254902, alpha: 1)
    }
}
