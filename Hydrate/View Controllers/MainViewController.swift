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
    
    fileprivate var dailyLog: DailyLog! {
        didSet {
            updateViews()
        }
    }
    
    fileprivate let dailyLogController = DailyLogController()
    
    fileprivate var targetDailyIntake: Int = 96
    
    fileprivate var intakeButtonAmounts = [8, 12, 16, 20, 32]
    
    fileprivate lazy var intakeButtonOffsets: [CGPoint] = {
        var offsets: [CGPoint] = []
        let buttonCount = intakeButtonAmounts.count
        let radius: CGFloat = 150
        let startAngleDeg: CGFloat = -145
        let stopAngleDeg: CGFloat = -35
        
        // compute angular distance between buttons
        let startAngle: CGFloat = startAngleDeg * .pi / 180
        let stopAngle: CGFloat = stopAngleDeg * .pi / 180
        let angularStep = (stopAngle - startAngle) / CGFloat(buttonCount - 1)
        
        for i in 0 ..< buttonCount {
            let xOffset = radius * cos(CGFloat(i) * angularStep + startAngle)
            let yOffset = radius * sin(CGFloat(i) * angularStep + startAngle) + 50
            offsets.append(CGPoint(x: xOffset, y: yOffset))
        }

        return offsets
    }()
    
    fileprivate var totalIntake: Int {
        Int(dailyLog.totalIntake)
    }
    
    fileprivate var waterLevel: CGFloat {
        guard let totalIntake = dailyLog?.totalIntake else { return 0 }
        return CGFloat(totalIntake) / CGFloat(targetDailyIntake) * ((view.bounds.maxY - measurementMarkersView.frame.minY) / view.bounds.maxY)
    }
    
    fileprivate var mostRecentIntakeEntryToday: IntakeEntry? {
        dailyLogController.fetchIntakeEntries(for: dailyLog).first
    }
    
    fileprivate lazy var coreDataStack = CoreDataStack.shared
    
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
            button.layer.shadowRadius = 2.0
            button.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            button.layer.shadowOpacity = 0.25
            button.backgroundColor = .intakeButtonColor
            button.alpha = 0.0
            button.setTitleColor(.intakeButtonTextColor, for: .normal)
            button.setTitle("\(intakeButtonAmounts[index]) oz.", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            button.addTarget(self, action: #selector(customWaterButtonTapped), for: .touchUpInside)
            buttons.append(button)
        }
        return buttons
    }()
    
    fileprivate let showDataButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendar-button"), for: .normal)
        button.tintColor = UIColor.actionColor
        button.contentHorizontalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0);
        button.addTarget(self, action: #selector(handleShowDataTapped), for: .touchUpInside)
        return button
    }()
    
    fileprivate let showSettingsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "settings-button"), for: .normal)
        button.tintColor = UIColor.actionColor
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadIntakeEntries),
                                               name: .todaysDailyLogDidUpdateNotificationName,
                                               object: nil)
        setupTapGestures()
        setupViews()
        loadIntakeEntries()
    }
    
    // Shake to undo last intake entry
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            guard let entryToDelete = mostRecentIntakeEntryToday else { return }
            undoAddWater(deletingIntakeEntry: entryToDelete)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Private Methods
    
    @objc fileprivate func reloadIntakeEntries() {
        let oldTotalIntake = dailyLog?.totalIntake ?? 0
        dailyLog = dailyLogController.fetchDailyLog()
        intakeAmountLabel.count(from: Float(oldTotalIntake), to: Float(dailyLog.totalIntake), duration: 0.4)
    }
    
    fileprivate func updateViews() {
        waterView.setWaterLevelHeight(waterLevel)
        intakeAmountLabel.countFromCurrent(to: Float(dailyLog.totalIntake), duration: 0.4)
    }
    
    fileprivate func loadIntakeEntries() {
        dailyLog = dailyLogController.fetchDailyLog()
        updateViews()
    }
    
    fileprivate func setupTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNormalPress))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longGesture.cancelsTouchesInView = false
        
        addWaterIntakeButton.addGestureRecognizer(tapGesture)
        addWaterIntakeButton.addGestureRecognizer(longGesture)
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = UIColor.backgroundColor
        waterView = WaterAnimationView(frame: view.frame)
        waterView.setWaterLevelHeight(0, animated: false)
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
        
        // Setup bottom buttons
        NSLayoutConstraint.activate([
            addWaterIntakeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addWaterIntakeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            addWaterIntakeButton.widthAnchor.constraint(equalToConstant: 98),
            addWaterIntakeButton.heightAnchor.constraint(equalToConstant: 98),
        ])
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mainViewTapped)))
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
    
    fileprivate func addWater(_ intakeAmount: Int, selectedButtonIndex: Int? = nil) {
        guard intakeAmount != 0 else { return }
        
        dailyLogController.add(intakeAmount: intakeAmount, to: dailyLog)
        
        let buttonIndex = selectedButtonIndex ?? 2
        var buttonCenter = addWaterIntakeButton.center
        buttonCenter.x += intakeButtonOffsets[buttonIndex].x
        buttonCenter.y += intakeButtonOffsets[buttonIndex].y
        let color: UIColor? = intakeAmount < 0 ? #colorLiteral(red: 0.5971726884, green: 0.2109181469, blue: 0.2735780059, alpha: 0.649614726) : nil
        let amountText = intakeAmount < 0 ? "\(intakeAmount)" : "+\(intakeAmount)"
        addWaterLabelAnimation(withText: amountText, startingCenterPoint: buttonCenter, textColor: color)
        
        intakeAmountLabel.count(from: Float(totalIntake), to: Float(totalIntake + intakeAmount), duration: 0.4)
        updateViews()
    }
    
    fileprivate func undoAddWater(deletingIntakeEntry intakeEntry: IntakeEntry) {
        let amount = intakeEntry.amount
        dailyLogController.delete(intakeEntry, from: dailyLog)
        
        var buttonCenter = addWaterIntakeButton.center
        buttonCenter.x += intakeButtonOffsets[2].x
        buttonCenter.y += intakeButtonOffsets[2].y
        
        addWaterLabelAnimation(withText: "\(-amount)", startingCenterPoint: buttonCenter, textColor: #colorLiteral(red: 0.5971726884, green: 0.2109181469, blue: 0.2735780059, alpha: 0.649614726))
        
        intakeAmountLabel.countFromCurrent(to: Float(dailyLog.totalIntake), duration: 0.4)
        updateViews()
    }
    
    // MARK: - Animations
    
    fileprivate func showIntakeButtons() {
        customWaterButtons.forEach { $0.alpha = 0.0 }
        let delayStep = 0.0 //0.05
        for i in customWaterButtons.indices {
            let delay: TimeInterval = delayStep * Double(i)
            UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                            self.customWaterButtons[i].transform = CGAffineTransform(translationX: self.intakeButtonOffsets[i].x,
                                                                                     y: self.intakeButtonOffsets[i].y)
                            self.customWaterButtons[i].alpha = 1.0
                           })
        }
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
                        self.addWaterIntakeButton.alpha = 0.4
                       })
        isShowingIntakeButtons = true
    }
    
    fileprivate func hideIntakeButtons(selectedButtonIndex: Int? = nil) {
        let delayStep = 0.0 //0.05
        for i in customWaterButtons.indices {
            let delay: TimeInterval = delayStep * Double(customWaterButtons.count - i - 1)
            UIView.animate(withDuration: 0.35, delay: delay, usingSpringWithDamping: 0.65,
                           initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                            self.customWaterButtons[i].transform = .identity
                            self.customWaterButtons[i].alpha = 0.0
                           })
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.addWaterIntakeButton.alpha = 1
        }
        
        isShowingIntakeButtons = false
    }
    
    @objc fileprivate func mainViewTapped() {
        if isShowingIntakeButtons {
            hideIntakeButtons()
        }
    }
    
    fileprivate func addWaterLabelAnimation(withText text: String, startingCenterPoint: CGPoint, textColor: UIColor? = nil) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.alpha = 0
        label.text = text
        label.textAlignment = .center
        label.textColor = textColor ?? .undeadWhite65
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.center = startingCenterPoint
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let centerYAnchor: NSLayoutConstraint = label.centerYAnchor.constraint(equalTo: view.topAnchor, constant: startingCenterPoint.y - 30)
        centerYAnchor.isActive = true
        label.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: startingCenterPoint.x).isActive = true
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.1, delay: 0.2, options: [.curveLinear]) {
            label.alpha = 1
        } completion: { animationDidFinish in
            guard animationDidFinish else {
                label.removeFromSuperview()
                return
            }
            
            UIView.animate(withDuration: 0.6, delay: 0.4, options: []) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }
        
        UIView.animate(withDuration: 1.2, delay: 0.1, options: []) {
            centerYAnchor.constant -= 60
            self.view.layoutIfNeeded()
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
        guard sender.tag >= 0, sender.tag < intakeButtonAmounts.count else { return }
        
        let intakeAmount = intakeButtonAmounts[sender.tag]
        addWater(intakeAmount, selectedButtonIndex: sender.tag)
        hideIntakeButtons(selectedButtonIndex: sender.tag)
    }
    
    // Add Water Button (Long Tap)
    
    @objc fileprivate func handleLongPress(sender : UILongPressGestureRecognizer){
        switch sender.state {
        case .began: handleGestureBegan(sender: sender)
        case .ended: handleGestureEnded(sender: sender)
        default: break
        }
    }
    
    fileprivate func handleGestureBegan(sender: UILongPressGestureRecognizer) {
        addWaterIntakeButton.isHighlighted = false
        addWaterIntakeButton.adjustsImageWhenHighlighted = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            self.addWaterIntakeButton.transform = .identity
        }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    fileprivate func handleGestureEnded(sender: UILongPressGestureRecognizer) {
        addWaterIntakeButton.adjustsImageWhenHighlighted = true
        guard let entryToDelete = mostRecentIntakeEntryToday else { return }
        undoAddWater(deletingIntakeEntry: entryToDelete)
    }
    
    // Page Navigation
    
    @objc fileprivate func handleShowDataTapped() {
        let dvc = DataViewController()
        present(dvc, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleShowSettingsTapped() {
        let svc = SettingsViewController()
        present(svc, animated: true, completion: nil)
    }
}
