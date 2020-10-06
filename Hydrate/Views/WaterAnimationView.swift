//
//  WaterAnimationView.swift
//  Hydrate
//
//  Created by David Wright on 9/15/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class WaterAnimationView: UIView {
    
    // MARK: - Public
    
    func setWaterLevelHeight(_ waterLevel: CGFloat, animated: Bool = true) {
        waterLevelHeight = waterLevel
        
        let waterLevelYPosition = bounds.maxY * (1 - waterLevelHeight)
        
        guard background.frame.origin.y > 0 || waterLevelYPosition > 0 else { return }
        
        if animated {
            UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseInOut, animations: {
                self.background.frame.origin.y = max(waterLevelYPosition, 0)
            }, completion: nil)
        } else {
            background.frame.origin.y = max(waterLevelYPosition, 0)
        }
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

     override func willMove(toSuperview newSuperview: UIView?) {
         super.willMove(toSuperview: newSuperview)
         
         if newSuperview == nil {
             displayLink?.invalidate()
         }
    }
    
    // MARK: - Private Properties
    
    private var waterLevelHeight: CGFloat = 0.0
    private weak var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private let waveAmplitude: CGFloat = 6.5
    private let waveSpeedFactor: CGFloat = 1.25
    private let delay: CGFloat = .pi / 2.0
    
    // MARK: - Private UI Components
    
    private lazy var background: UIView = {
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.layer.addSublayer(waveLayerBackground)
        background.layer.addSublayer(waveLayerForeground)
        return background
    }()

    private lazy var waveLayerForeground: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.waterColor.cgColor
        return shapeLayer
    }()
    
    private lazy var waveLayerBackground: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.waterColor.cgColor
        return shapeLayer
    }()
}

// MARK: - Private Methods

private extension WaterAnimationView {
    
    func configure() {
        addSubview(background)
        background.bounds.origin.y = 0
        background.anchor(top: nil, leading: leadingAnchor,
                          bottom: bottomAnchor, trailing: trailingAnchor)
        startDisplayLink()
    }

    func wave(at elapsed: Double, delay: CGFloat = 0) -> UIBezierPath? {
        guard bounds.width > 0, bounds.height > 0 else { return nil }

        func f(_ x: CGFloat) -> CGFloat {
            let elapsed = CGFloat(elapsed)
            let value = sin(((elapsed / waveSpeedFactor + x) * 1.25 * .pi) + delay)
            return value * waveAmplitude + bounds.height
        }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        
        let count = Int(bounds.width / 20)

        for step in 0...count {
            let dataPoint = CGFloat(step) / CGFloat(count)
            let x = dataPoint * bounds.width + bounds.minX
            let y = bounds.maxY - f(dataPoint)
            let point = CGPoint(x: x, y: y)
            path.addLine(to: point)
        }
        
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.close()
        return path
    }

    func startDisplayLink() {
        startTime = CACurrentMediaTime()
        displayLink?.invalidate()
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }

    func stopDisplayLink() {
        displayLink?.invalidate()
    }

    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - startTime
        waveLayerForeground.path = wave(at: elapsed)?.cgPath
        waveLayerBackground.path = wave(at: elapsed, delay: delay)?.cgPath
    }
}
