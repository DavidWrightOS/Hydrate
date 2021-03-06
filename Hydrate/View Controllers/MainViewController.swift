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
    
    private let dailyLogController = DailyLogController()
    
    private let notificationManager = LocalNotificationManager()
    
    private var targetDailyIntake: Double = HydrateSettings.targetDailyIntake
    
    private var units = HydrateSettings.unit
    
    private var intakeButtonAmounts: [Double] {
        switch units {
        case .milliliters: return [125, 250, 500, 750, 1000]
        case .fluidOunces: return [8, 12, 16, 20, 32]
        case .cups: return [1, 2, 3, 4, 5]
        }
    }
    
    private lazy var intakeButtonOffsets: [CGPoint] = {
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
    
    private var totalIntake: Double {
        (dailyLogController.dailyLog?.totalIntake ?? 0) * units.conversionFactor
    }
    
    private var waterLevel: CGFloat {
        CGFloat(totalIntake) / CGFloat(targetDailyIntake) *
            ((view.bounds.maxY - measurementMarkersView.frame.minY) / view.bounds.maxY)
    }
    
    //MARK: - UI Components
    
    private var waterView: WaterAnimationView!
    
    private let addWaterIntakeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "water-button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        let image = UIImage(systemName: "multiply.circle.fill")?.withConfiguration(config)
        button.setImage(image?.withTintColor(.undeadWhite, renderingMode: .alwaysOriginal), for: .selected)
        button.setImage(image?.withTintColor(UIColor.init(hex: 0xB3A298), renderingMode: .alwaysOriginal), for: [.selected, .highlighted])
        return button
    }()
    
    private lazy var customWaterButtons: [UIButton] = {
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
            button.setTitle("\(intakeButtonAmounts[index].roundedString) \(units.abbreviation)", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            button.addTarget(self, action: #selector(customWaterButtonTapped), for: .touchUpInside)
            buttons.append(button)
        }
        return buttons
    }()
    
    private let showDataButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 38, weight: .light)
        let image = UIImage(systemName: "chart.bar.xaxis")?.withConfiguration(config)
        button.setImage(image?.withTintColor(.undeadWhite, renderingMode: .alwaysOriginal), for: .normal)
        button.tintColor = UIColor.actionColor
        button.contentHorizontalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        button.addTarget(self, action: #selector(handleShowDataTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 58).isActive = true
        button.widthAnchor.constraint(equalToConstant: 58).isActive = true
        return button
    }()
    
    private let showSettingsButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 38, weight: .light)
        let image = UIImage(systemName: "gearshape")?.withConfiguration(config)
        button.setImage(image?.withTintColor(.undeadWhite, renderingMode: .alwaysOriginal), for: .normal)
        button.tintColor = UIColor.actionColor
        button.contentHorizontalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0);
        button.addTarget(self, action: #selector(handleShowSettingsTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 58).isActive = true
        button.widthAnchor.constraint(equalToConstant: 58).isActive = true
        return button
    }()
    
    private let intakeAmountLabel: AnimatedLabel = {
        let label = AnimatedLabel()
        label.unitsString = HydrateSettings.unit.abbreviation
        label.textAlignment = .center
        label.textColor = .undeadWhite
        label.font = UIFont.boldSystemFont(ofSize: 52)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topControlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .top
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let measurementMarkersView: MeasurementMarkerView = {
        let view = MeasurementMarkerView()
        view.unitsString = HydrateSettings.unit.abbreviation
        return view
    }()
    
    private var confettiView: ConfettiView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        targetDailyIntake = HydrateSettings.targetDailyIntake
        
        registerForSettingsChanges()
        registerForNotificationSettingsChanges()
        registerForNotificationsEnabledSettingChanges()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dailyLogDidUpdate),
                                               name: .todaysDailyLogDidUpdateNotificationName,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dailyLogDidUpdate),
                                               name: .NSCalendarDayChanged,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        setupTapGestures()
        setupViews()
        reloadIntakeEntries()
        rescheduleLocalNotifications()
    }
    
    /// Restart the water animation at the correct height when the app is brought to the foreground
    @objc private func applicationWillEnterForeground() {
        DispatchQueue.main.async {
            self.waterView.setWaterLevelHeight(self.waterLevel, animated: false)
        }
    }
    
    /// Shake to undo last intake entry added
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            presentUndoAlert()
        }
    }
    
    private func presentUndoAlert() {
        guard dailyLogController.lastIntakeEntryAddedToday != nil else { return }
        
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        
        presentAlert(title: "Undo Last Intake",
                     message: nil,
                     actionButtonText: "Undo",
                     options: [.isCancellable]) { [weak self] _ in
            guard let self = self else { return }
            self.undoLastIntakeEntry()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    //MARK: - Private Methods
    
    @objc private func dailyLogDidUpdate() {
        reloadIntakeEntries()
        rescheduleLocalNotifications()
    }
    
    private func reloadIntakeEntries() {
        dailyLogController.loadDailyLog()
        updateViews()
    }
    
    private func updateViews() {
        DispatchQueue.main.async {
            
            if self.targetDailyIntake != HydrateSettings.targetDailyIntake {
                self.targetDailyIntake = HydrateSettings.targetDailyIntake
                self.measurementMarkersView.updateMarkers()
            }
            
            if self.units != HydrateSettings.unit {
                self.units = HydrateSettings.unit
                self.intakeAmountLabel.unitsString = self.units.abbreviation
                self.measurementMarkersView.unitsString = self.units.abbreviation
                
                self.customWaterButtons.forEach {
                    $0.setTitle("\(self.intakeButtonAmounts[$0.tag].roundedString) \(self.units.abbreviation)", for: .normal)
                }
            }
            
            self.waterView.setWaterLevelHeight(self.waterLevel)
            self.intakeAmountLabel.countFromCurrent(to: Float(self.totalIntake), duration: 0.4)
        }
    }
    
    private func setupTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNormalPress))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longGesture.cancelsTouchesInView = false
        
        addWaterIntakeButton.addGestureRecognizer(tapGesture)
        addWaterIntakeButton.addGestureRecognizer(longGesture)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDownGesture))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    private func setupViews() {
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
        setupMeasurementMarkerView()
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
    
    private func setupTopControls() {
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
    
    private func setupIntakeLabels() {
        NSLayoutConstraint.activate([
            intakeAmountLabel.centerYAnchor.constraint(equalTo: topControlsStackView.centerYAnchor, constant: -4),
            intakeAmountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        customWaterButtons.forEach { $0.center = self.addWaterIntakeButton.center }
        measurementMarkersView.updateMarkers()
    }
    
    // MARK: - Measurement Markers
    
    private func setupMeasurementMarkerView() {
        measurementMarkersView.anchor(top: topControlsStackView.bottomAnchor,
                                      leading: view.safeAreaLayoutGuide.leadingAnchor,
                                      bottom: view.bottomAnchor,
                                      trailing: view.safeAreaLayoutGuide.trailingAnchor,
                                      padding: .init(top: 36, left: 16, bottom: 0, right: 16))
    }
    
    private func addWater(_ intakeAmount: Double, selectedButtonIndex: Int? = nil) {
        guard intakeAmount != 0 else { return }
        
        if totalIntake < targetDailyIntake, totalIntake + intakeAmount >= targetDailyIntake {
            showConfettiAnimation()
        }
        
        let normalizedIntakeAmount = intakeAmount / units.conversionFactor
        dailyLogController.add(intakeAmount: normalizedIntakeAmount)
        
        let buttonIndex = selectedButtonIndex ?? 2
        var buttonCenter = addWaterIntakeButton.center
        buttonCenter.x += intakeButtonOffsets[buttonIndex].x
        buttonCenter.y += intakeButtonOffsets[buttonIndex].y
        
        let color: UIColor? = intakeAmount < 0 ? .negativeNumberRed : nil
        let amountText = intakeAmount < 0 ? "\(intakeAmount.roundedString)" : "+\(intakeAmount.roundedString)"
        addWaterLabelAnimation(withText: amountText, startingCenterPoint: buttonCenter, textColor: color)
        
        updateViews()
    }
    
    private func undoLastIntakeEntry() {
        let amount = dailyLogController.undoLastIntakeEntry()
        guard amount != 0 else { return }
        
        let amountInCurrentUnit = Int((amount * units.conversionFactor).rounded())
        var buttonCenter = addWaterIntakeButton.center
        buttonCenter.x += intakeButtonOffsets[2].x
        buttonCenter.y += intakeButtonOffsets[2].y
        
        addWaterLabelAnimation(withText: "\(-amountInCurrentUnit)", startingCenterPoint: buttonCenter, textColor: .negativeNumberRed)
        
        updateViews()
    }
    
    // MARK: - Animations
    
    private func showIntakeButtons(staggerAnimationsBy staggerInterval: Double = 0.0) {
        customWaterButtons.forEach { $0.alpha = 0.0 }
        let delayStep = staggerInterval
        for i in customWaterButtons.indices {
            let delay: TimeInterval = delayStep * Double(i)
            UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.customWaterButtons[i].transform = CGAffineTransform(translationX: self.intakeButtonOffsets[i].x, y: self.intakeButtonOffsets[i].y)
                self.customWaterButtons[i].alpha = 1.0
            })
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
            self.addWaterIntakeButton.alpha = 0.4
        })
        
        isShowingIntakeButtons = true
        addWaterIntakeButton.isSelected = true
    }
    
    private func hideIntakeButtons(selectedButtonIndex: Int? = nil, staggerAnimationsBy staggerInterval: Double = 0.0) {
        addWaterIntakeButton.isSelected = false
        let delayStep = staggerInterval
        for i in customWaterButtons.indices {
            let delay: TimeInterval = delayStep * Double(customWaterButtons.count - i - 1)
            UIView.animate(withDuration: 0.35, delay: delay, usingSpringWithDamping: 0.65, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.customWaterButtons[i].transform = .identity
                self.customWaterButtons[i].alpha = 0.0
            })
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.addWaterIntakeButton.alpha = 1
        }
        
        isShowingIntakeButtons = false
    }
    
    @objc private func mainViewTapped() {
        if isShowingIntakeButtons {
            hideIntakeButtons()
        }
    }
    
    private func addWaterLabelAnimation(withText text: String, startingCenterPoint: CGPoint, textColor: UIColor? = nil) {
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
    
    private func showConfettiAnimation() {
        confettiView?.removeFromSuperview()
        confettiView = nil
        
        let confettiView = ConfettiView(frame: view.frame)
        self.confettiView = confettiView
        view.addSubview(confettiView)
        
        confettiView.delegate = self
        confettiView.animateConfetti()
    }
    
    // MARK: - UIButton Selectors
    
    // Add Water Button (Short Tap)
    
    private var isShowingIntakeButtons = false
    
    @objc private func handleNormalPress() {
        if isShowingIntakeButtons {
            hideIntakeButtons()
        } else {
            showIntakeButtons()
        }
    }
    
    @objc private func customWaterButtonTapped(_ sender: UIButton) {
        guard sender.tag >= 0, sender.tag < intakeButtonAmounts.count else { return }
        
        let intakeAmount = intakeButtonAmounts[sender.tag]
        addWater(intakeAmount, selectedButtonIndex: sender.tag)
        hideIntakeButtons(selectedButtonIndex: sender.tag)
    }
    
    // Add Water Button (Long Tap)
    
    @objc private func handleLongPress(sender : UILongPressGestureRecognizer) {
        switch sender.state {
        case .began: handleGestureBegan(sender: sender)
        case .ended: handleGestureEnded(sender: sender)
        default: break
        }
    }
    
    private func handleGestureBegan(sender: UILongPressGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            self.addWaterIntakeButton.transform = .identity
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        if isShowingIntakeButtons {
            hideIntakeButtons(staggerAnimationsBy: 0.05)
        } else {
            showIntakeButtons(staggerAnimationsBy: 0.05)
        }
    }
    
    private func handleGestureEnded(sender: UILongPressGestureRecognizer) {
        
    }
    
    @objc private func handleSwipeDownGesture() {
        presentUndoAlert()
    }
    
    // Page Navigation
    
    @objc private func handleShowDataTapped() {
        let dvc = DataViewController(dailyLogController: dailyLogController)
        dvc.dailyLogController = dailyLogController
        present(dvc, animated: true, completion: nil)
    }
    
    @objc private func handleShowSettingsTapped() {
        let svc = SettingsViewController(notificationManager: notificationManager)
        present(svc, animated: true, completion: nil)
    }
}

// MARK: - ConfettiView Delegate

extension MainViewController: ConfettiViewDelegate {
    func animationDidEnd() {
        confettiView?.removeFromSuperview()
        confettiView = nil
    }
}

// MARK: - SettingsTracking

extension MainViewController: SettingsTracking {
    
    func settingsDataChanged() {
        updateViews()
    }
    
    func notificationSettingsDataChanged() {
        rescheduleLocalNotifications()
    }
    
    func notificationsEnabledSettingDataChanged() {
        rescheduleLocalNotifications()
    }
}

// MARK: - Local Notifications

extension MainViewController {
    
    private func rescheduleLocalNotifications() {
        notificationManager.removeAllPendingNotifications()
        
        guard HydrateSettings.notificationsEnabled else { return }
        
        notificationManager.requestAuthorization() { [weak self] granted in
            if granted {
                self?.scheduleLocalNotifications()
            } else {
                HydrateSettings.notificationsEnabled = false
            }
        }
    }
    
    private func scheduleLocalNotifications() {
        
        let notificationsStartTime = dateComponentsFrom(minutes: HydrateSettings.wakeUpTime)
        let notificationsEndTime = dateComponentsFrom(minutes: HydrateSettings.bedTime)
        let numberOfNotifications = HydrateSettings.notificationsPerDay
        
        let notificationInterval = notificationsStartTime.date!.distance(to: notificationsEndTime.date!) / Double(numberOfNotifications)
        
        let notificationBody = "Time to drink some more water 💧"
        let content = LocalNotificationContentModel(body: notificationBody)
        
        for intervalCount in 0..<numberOfNotifications {
            let timeFromStart = notificationInterval * Double(intervalCount)
            let date = notificationsStartTime.date!.addingTimeInterval(timeFromStart)
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
            
            print("Scheduling notification #\(intervalCount + 1) at time: \(dateComponents.hour ?? 0):\(dateComponents.minute ?? 0)")
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            notificationManager.scheduleNotification(trigger: trigger, content: content) { text in
                NSLog("Notification not scheduled for: \"\(text)\"")
            }
        }
    }
    
    private func dateComponentsFrom(minutes: Int) -> DateComponents {
        let minutes = minutes % (60 * 24)
        let hoursComponent = minutes / 60
        let minutesComponent = minutes - hoursComponent * 60
        return DateComponents(calendar: Calendar.current, hour: hoursComponent, minute: minutesComponent)
    }
}
