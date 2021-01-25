//
//  MeasurementMarkerView.swift
//  Hydrate
//
//  Created by David Wright on 10/23/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class MeasurementMarkerView: UIView {
    
    // MARK: - Public
    
    var markerIntervalSize = 8 // number of water units (i.e. ounces) between measurement markers
    var markerUnitsString = "oz."
    var markerTextColor = UIColor.markerLabelColor
    var markerLineColor = UIColor.markerLineColor
    var markerLabelFont = UIFont.boldSystemFont(ofSize: 20)
    
    func updateMarkers() {
        subviews.forEach { $0.removeFromSuperview() }
        setupMeasurementMarkers()
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    // MARK: - Private
    
    fileprivate var topMarkerView = UIView()
    fileprivate var bottomMarkersStackView = UIStackView()
    
    fileprivate func configure() {
        backgroundColor = .clear
        setupMeasurementMarkers()
    }
    
    fileprivate func setupMeasurementMarkers() {
        let targetDailyIntake = HydrateSettings.targetDailyIntake
        let topMarkerIntervalOffset = targetDailyIntake % markerIntervalSize
        var topMarkerInterval = (topMarkerIntervalOffset == 0) ? markerIntervalSize : topMarkerIntervalOffset
        var topMarkerIntervalHeight = bounds.height * CGFloat(topMarkerInterval) / CGFloat(targetDailyIntake)
        
        if topMarkerIntervalHeight < 24 {
            topMarkerInterval += markerIntervalSize
            topMarkerIntervalHeight = bounds.height * CGFloat(topMarkerInterval) / CGFloat(targetDailyIntake)
        }
        
        // create top most measurement marker
        topMarkerView = newMarkerView(withDisplayNumber: targetDailyIntake)
        
        // create all remaining measurement markers and put them in a stackView
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        bottomMarkersStackView = stackView
        
        let nextMarkerNumber = targetDailyIntake - topMarkerInterval
        
        for markerNumber in stride(from: nextMarkerNumber, to: 0, by: -markerIntervalSize) {
            let markerView = newMarkerView(withDisplayNumber: markerNumber)
            bottomMarkersStackView.addArrangedSubview(markerView)
        }
        
        addSubview(topMarkerView)
        addSubview(bottomMarkersStackView)
        
        topMarkerView.heightAnchor.constraint(equalToConstant: topMarkerIntervalHeight).isActive = true
        
        topMarkerView.anchor(top: topAnchor,
                             leading: leadingAnchor,
                             bottom: nil,
                             trailing: trailingAnchor)
        
        bottomMarkersStackView.anchor(top: topMarkerView.bottomAnchor,
                                      leading: leadingAnchor,
                                      bottom: bottomAnchor,
                                      trailing: trailingAnchor)
    }
    
    fileprivate func newMarkerView(withDisplayNumber displayNumber: Int) -> UIView {
        guard displayNumber > 0 else { return UIView() }
        
        let markerView = UIView()
        let label = UILabel()
        let lineView = UIView()
        markerView.addSubview(label)
        markerView.addSubview(lineView)
        
        label.textAlignment = .right
        label.font = markerLabelFont
        label.textColor = markerTextColor
        label.text = "\(displayNumber) \(markerUnitsString)"
        
        lineView.backgroundColor = markerLineColor
        
        markerView.translatesAutoresizingMaskIntoConstraints = false
        
        label.anchor(top: nil,
                     leading: markerView.leadingAnchor,
                     bottom: markerView.topAnchor,
                     trailing: nil,
                     padding: .init(top: 0, left: 0, bottom: -4, right: 0))
        
        lineView.anchor(top: nil,
                        leading: label.trailingAnchor,
                        bottom: markerView.topAnchor,
                        trailing: markerView.trailingAnchor,
                        padding: .init(top: 0, left: 8, bottom: 0, right: 0))
        
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return markerView
    }
}
    
