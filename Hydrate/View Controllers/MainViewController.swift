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
    
    fileprivate let customWaterButtons: [UIButton] = {
        var buttons = [UIButton]()
        let buttonIntakeAmounts = [8, 12, 16, 20, 32]
        let buttonDiameter: CGFloat = 80
        for i in 0..<5 {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: buttonDiameter).isActive = true
            button.heightAnchor.constraint(equalToConstant: buttonDiameter).isActive = true
            button.layer.cornerRadius = buttonDiameter / 2
            button.backgroundColor = .green
            button.setTitle("+\(buttonIntakeAmounts[i]) oz.", for: .normal)
            buttons.append(button)
        }
        return buttons
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
        setupTapGestures()
        setupViews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Private Methods
    
    fileprivate func setupTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNormalPress))
        addWaterIntakeButton.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = UIColor.ravenClawBlue
        waterView = WaterAnimationView(frame: CGRect(origin: .zero, size: view.bounds.size))
        view.addSubview(waterView)
        
        // Add subviews
        view.addSubview(measurementMarkersView)
        view.addSubview(topControlsStackView)
        view.addSubview(intakeAmountLabel)
        view.addSubview(addWaterIntakeButton)
        
        // Setup subviews
        setupWaterIntakeButtons()
        setupMeasurementMarkers()
        setupTopControls()
        setupIntakeLabels()
        updateViews()
        
        // Setup bottom buttons
        NSLayoutConstraint.activate([
            addWaterIntakeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addWaterIntakeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            addWaterIntakeButton.widthAnchor.constraint(equalToConstant: 98),
            addWaterIntakeButton.heightAnchor.constraint(equalToConstant: 98),
        ])
    }
    
    fileprivate func setupTopControls() {
        topControlsStackView.addArrangedSubview(showHistoryButton)
        topControlsStackView.addArrangedSubview(UIView()) // spacer view
        topControlsStackView.addArrangedSubview(showSettingsButton)
        
        NSLayoutConstraint.activate([
            topControlsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topControlsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            topControlsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            topControlsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
        fileprivate func setupIntakeLabels() {
        NSLayoutConstraint.activate([
            intakeAmountLabel.centerYAnchor.constraint(equalTo: topControlsStackView.centerYAnchor, constant: -7),
            intakeAmountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    fileprivate func setupWaterIntakeButtons() {
        for button in customWaterButtons {
            view.addSubview(button)
            button.center = addWaterIntakeButton.center
            button.centerYAnchor.constraint(equalTo: addWaterIntakeButton.centerYAnchor).isActive = true
            button.centerXAnchor.constraint(equalTo: addWaterIntakeButton.centerXAnchor).isActive = true
        }
    }
    
    fileprivate func updateViews() {
        intakeAmountLabel.text = "\(totalIntake) oz."
    }
    
    // MARK: - Measurement Markers
    
    fileprivate func setupMeasurementMarkers() {
        let markerIntervalSize = 8 // number of water units (i.e. ounces) between measurement markers
        
        measurementMarkersView.anchor(top: topControlsStackView.bottomAnchor,
                                      leading: view.safeAreaLayoutGuide.leadingAnchor,
                                      bottom: view.bottomAnchor,
                                      trailing: view.safeAreaLayoutGuide.trailingAnchor,
                                      padding: .init(top: 36, left: 16, bottom: 0, right: 16))
        
        let topPadding: CGFloat = 36
        let fullMarkerViewHeight = view.bounds.height - topPadding - 104 // topControlsStackView.frame.maxY = 104
        
        let topMarkerIntervalOffset = targetDailyIntake % markerIntervalSize
        var topMarkerInterval = (topMarkerIntervalOffset == 0) ? markerIntervalSize : topMarkerIntervalOffset
        var topMarkerIntervalHeight = fullMarkerViewHeight * CGFloat(topMarkerInterval) / CGFloat(targetDailyIntake)
        
        if topMarkerIntervalHeight < 24 {
            topMarkerInterval += markerIntervalSize
            topMarkerIntervalHeight = fullMarkerViewHeight * CGFloat(topMarkerInterval) / CGFloat(targetDailyIntake)
        }
        
        // create top most measurement marker
        let topMarkerView = newMarkerView(withDisplayNumber: targetDailyIntake)
        
        // create all remaining measurement markers and put them in a stackView
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        let nextMarkerNumber = targetDailyIntake - topMarkerInterval
        
        for markerNumber in stride(from: nextMarkerNumber, to: 0, by: -markerIntervalSize) {
            let markerView = newMarkerView(withDisplayNumber: markerNumber)
            stackView.addArrangedSubview(markerView)
        }
        
        measurementMarkersView.addSubview(topMarkerView)
        measurementMarkersView.addSubview(stackView)
        
        topMarkerView.heightAnchor.constraint(equalToConstant: topMarkerIntervalHeight).isActive = true
        
        topMarkerView.anchor(top: measurementMarkersView.topAnchor,
                             leading: measurementMarkersView.leadingAnchor,
                             bottom: nil,
                             trailing: measurementMarkersView.trailingAnchor)
        
        stackView.anchor(top: topMarkerView.bottomAnchor,
                         leading: measurementMarkersView.leadingAnchor,
                         bottom: measurementMarkersView.bottomAnchor,
                         trailing: measurementMarkersView.trailingAnchor)
    }
    
    fileprivate func newMarkerView(withDisplayNumber displayNumber: Int) -> UIView {
        guard displayNumber > 0 else { return UIView() }
        
        let markerView = UIView()
        let label = UILabel()
        let lineView = UIView()
        markerView.addSubview(label)
        markerView.addSubview(lineView)
        
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .markerLabelColor
        label.text = "\(displayNumber) oz."
        
        lineView.backgroundColor = .markerLineColor
        
        markerView.translatesAutoresizingMaskIntoConstraints = false
        label.anchor(top: nil, leading: markerView.leadingAnchor, bottom: markerView.topAnchor, trailing: nil,
                     padding: .init(top: 0, left: 0, bottom: -4, right: 0))
        lineView.anchor(top: nil, leading: label.trailingAnchor, bottom: markerView.topAnchor, trailing: markerView.trailingAnchor,
                        padding: .init(top: 0, left: 8, bottom: 0, right: 0))
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return markerView
    }
    
    // MARK: - UIButton Selectors
    
    // Add Water Button (Short Tap)
    
    @objc fileprivate func handleNormalPress(){
        totalIntake = totalIntake > targetDailyIntake * 2 ? 0 : totalIntake + 12
    }
    
    // Page Navigation
    
    @objc fileprivate func handleShowHistoryTapped() {
        print("DEBUG: Show History View Controller..")
    }
    
    @objc fileprivate func handleShowSettingsTapped() {
        print("DEBUG: Show Settings View Controller..")
    }
}
