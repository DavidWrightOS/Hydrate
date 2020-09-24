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
    var buttonIntakeAmounts = [8, 12, 16, 20, 32]
    
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
    
    fileprivate lazy var customWaterButtons: [UIButton] = {
        var buttons = [UIButton]()
        let buttonDiameter: CGFloat = 60
        for index in 0..<5 {
            let button = UIButton()
            button.tag = index
            button.bounds.size = CGSize(width: buttonDiameter, height: buttonDiameter)
            button.layer.cornerRadius = buttonDiameter / 2
            button.backgroundColor = #colorLiteral(red: 0.1022377216, green: 0.5984256684, blue: 0.8548628818, alpha: 1)
            button.setTitleColor(.white, for: .normal) // #colorLiteral(red: 0.2875679024, green: 0.5309943961, blue: 0.5983251284, alpha: 1)
            button.setTitle("\(buttonIntakeAmounts[index]) oz.", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            button.addTarget(self, action: #selector(customWaterButtonTapped), for: .touchUpInside)
            buttons.append(button)
        }
        return buttons
    }()
    
    fileprivate let showDataButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendar-button"), for: .normal)
        button.tintColor = UIColor.undeadWhite
        button.contentHorizontalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0);
        button.addTarget(self, action: #selector(handleShowDataTapped), for: .touchUpInside)
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
    
    fileprivate let intakeAmountLabel: AnimatedLabel = {
        let label = AnimatedLabel()
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
        waterView = WaterAnimationView(frame: view.frame)
        view.addSubview(waterView)
        
        // Add subviews
        view.addSubview(measurementMarkersView)
        view.addSubview(topControlsStackView)
        view.addSubview(intakeAmountLabel)
        customWaterButtons.forEach { view.addSubview($0) }
        view.addSubview(addWaterIntakeButton)
        
        // Setup subviews
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
        
        //setupWaterIntakeButtons()
    }
    
    fileprivate func setupTopControls() {
        topControlsStackView.addArrangedSubview(showDataButton)
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
            intakeAmountLabel.centerYAnchor.constraint(equalTo: topControlsStackView.centerYAnchor, constant: -4),
            intakeAmountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        customWaterButtons.forEach { $0.center = self.addWaterIntakeButton.center }
    }
    
    fileprivate func intakeButtonOffets(buttonCount: Int, radius: CGFloat) -> [CGPoint] {
        var offsets: [CGPoint] = []
        let startAngleDeg: CGFloat = -200
        let stopAngleDeg: CGFloat = 20
        
        // compute angular distance between buttons
        let startAngle: CGFloat = startAngleDeg * .pi / 180
        let stopAngle: CGFloat = stopAngleDeg * .pi / 180
        let angularStep = (stopAngle - startAngle) / CGFloat(buttonCount - 1)
        
        for i in 0 ..< buttonCount {
            let xOffset = radius * cos(CGFloat(i) * angularStep + startAngle)
            let yOffset = radius * sin(CGFloat(i) * angularStep + startAngle)
            offsets.append(CGPoint(x: xOffset, y: yOffset))
        }

        return offsets
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
    
    fileprivate func addWater(_ intakeAmount: Int) {
        intakeAmountLabel.count(from: Float(totalIntake), to: Float(totalIntake + intakeAmount), duration: 0.4)
        totalIntake += intakeAmount
    }
    
    // MARK: - Animations
    
    fileprivate func showIntakeButtons() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let buttonOffsets = self.intakeButtonOffets(buttonCount: self.customWaterButtons.count, radius: 90)
            self.customWaterButtons.forEach { $0.transform = CGAffineTransform(translationX: buttonOffsets[$0.tag].x, y: buttonOffsets[$0.tag].y) }
            self.addWaterIntakeButton.alpha = 0.5
        })
        isShowingIntakeButtons = true
    }
    
    fileprivate func hideIntakeButtons(selectedButtonIndex: Int? = nil) {
        if let selectedButtonIndex = selectedButtonIndex {
            addWaterLabelAnimation(withText: "+\(buttonIntakeAmounts[selectedButtonIndex])",
                                   startingCenterPoint: customWaterButtons[selectedButtonIndex].center)
        }
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.customWaterButtons.forEach { $0.transform = .identity }
            self.addWaterIntakeButton.alpha = 1
        }
        isShowingIntakeButtons = false
    }
    
    fileprivate func addWaterLabelAnimation(withText text: String, startingCenterPoint: CGPoint) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.alpha = 1
        label.text = text
        label.textAlignment = .center
        label.textColor = .undeadWhite65
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.center = startingCenterPoint
        label.center.y -= 60
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let centerYAnchor: NSLayoutConstraint = label.centerYAnchor.constraint(equalTo: view.topAnchor, constant: startingCenterPoint.y - 60)
        centerYAnchor.isActive = true
        label.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: startingCenterPoint.x).isActive = true
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.1, delay: 0, options: []) {
            label.alpha = 1
        }
        UIView.animate(withDuration: 1.2, delay: 0, options: []) {
            centerYAnchor.constant -= 60
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.7, delay: 0.5, options: []) {
            label.alpha = 0
        } completion: { _ in
            label.removeFromSuperview()
        }
    }
    
    // MARK: - UIButton Selectors
    
    // Add Water Button (Short Tap)
    
    fileprivate var isShowingIntakeButtons = false
    
    @objc fileprivate func handleNormalPress() {
        if isShowingIntakeButtons {
            hideIntakeButtons()
        } else {
            showIntakeButtons()
        }
    }
    
    @objc fileprivate func customWaterButtonTapped(_ sender: UIButton) {
        guard sender.tag >= 0, sender.tag < buttonIntakeAmounts.count else { return }
        
        let intakeAmount = buttonIntakeAmounts[sender.tag]
        addWater(intakeAmount)
        hideIntakeButtons(selectedButtonIndex: sender.tag)
    }
    
    // Page Navigation
    
    @objc fileprivate func handleShowDataTapped() {
        let dvc = DataViewController()
        present(dvc, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleShowSettingsTapped() {
        print("DEBUG: Show Settings View Controller..")
    }
}
