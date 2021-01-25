//
//  ConfettiView.swift
//  Hydrate
//
//  Created by David Wright on 1/25/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import UIKit

protocol ConfettiViewDelegate: class {
    func animationDidEnd()
}

class ConfettiView: UIView {
    
    private var confettiTypes: [ConfettiType] = {
        return [ConfettiPosition.foreground, ConfettiPosition.background].flatMap { position in
            return [ConfettiShape.rectangle, ConfettiShape.circle].flatMap { shape in
                return UIColor.confettiColors.map { color in
                    return ConfettiType(color: color, shape: shape, position: position)
                }
            }
        }
    }()
    
    private func createConfettiCells() -> [CAEmitterCell] {
        return confettiTypes.map { confettiType in
            let cell = CAEmitterCell()
            cell.name = confettiType.name
            
            // Emit "falling" and spinning confetti cells
            cell.beginTime = 0.1
            cell.birthRate = 30
            cell.contents = confettiType.image.cgImage
            cell.emissionRange = CGFloat(Double.pi)
            cell.lifetime = 4
            cell.spin = 7
            cell.spinRange = 12
            cell.velocityRange = 0
            cell.yAcceleration = 0
            
            // Add 3D Rotation
            cell.setValue("plane", forKey: "particleType")
            cell.setValue(Double.pi, forKey: "orientationRange")
            cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
            cell.setValue(Double.pi / 2, forKey: "orientationLatitude")
            
            return cell
        }
    }
    
    private var foregroundConfettiLayer: CAEmitterLayer!
    private var backgroundConfettiLayer: CAEmitterLayer!
    
    private weak var timer: Timer?
    
    weak var delegate: ConfettiViewDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if superview != nil, newSuperview == nil {
            stopTimer()
        }
    }
}


// MARK: - Configure View

extension ConfettiView {
    private func configure() {
        setupConfettiLayers()
        isUserInteractionEnabled = false
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            self.delegate?.animationDidEnd()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func animateConfetti() {
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        for layer in [foregroundConfettiLayer, backgroundConfettiLayer] {
            addBehaviors(to: layer!)
            addAnimations(to: layer!)
        }
        
        startTimer()
    }
    
    private func setupConfettiLayers() {
        let foregroundLayer = createConfettiLayer()
        layer.addSublayer(foregroundLayer)
        foregroundConfettiLayer = foregroundLayer
        
        let backgroundLayer = createConfettiLayer()
        for emitterCell in backgroundLayer.emitterCells ?? [] {
            emitterCell.scale = 0.7
        }
        backgroundLayer.opacity = 0.4
        backgroundLayer.speed = 0.94
        layer.addSublayer(backgroundLayer)
        backgroundConfettiLayer = backgroundLayer
    }
    
    // Add CAEmitterBehaviors
    private func addBehaviors(to layer: CAEmitterLayer) {
        let behaviors = [ horizontalWaveBehavior(),
                          verticalWaveBehavior(),
                          attractorBehavior(for: layer),
                          dragBehavior() ]
        layer.setValue(behaviors, forKey: "emitterBehaviors")
    }
    
    // Add CAAnimations
    private func addAnimations(to layer: CAEmitterLayer) {
        addAttractorAnimation(to: layer)
        addBirthrateAnimation(to: layer)
        addGravityAnimation(to: layer)
        addDragAnimation(to: layer)
    }
    
    private func createConfettiLayer() -> CAEmitterLayer {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.birthRate = 0
        emitterLayer.emitterCells = createConfettiCells()
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.minY - 100)
        emitterLayer.emitterSize = CGSize(width: 100, height: 100)
        emitterLayer.emitterShape = .sphere
        emitterLayer.frame = bounds
        emitterLayer.beginTime = CACurrentMediaTime()
        return emitterLayer
    }
}


// MARK: - CAEmitterBehaviors

extension ConfettiView {
    
    // Simulate horizontal air resistance
    private func horizontalWaveBehavior() -> Any {
        let behavior = createBehavior(type: "wave")
        behavior.setValue([100, 0, 0], forKeyPath: "force")
        behavior.setValue(0.5, forKeyPath: "frequency")
        return behavior
    }
    
    // Simulate vertical air resistance
    private func verticalWaveBehavior() -> Any {
        let behavior = createBehavior(type: "wave")
        behavior.setValue([0, 500, 0], forKeyPath: "force")
        behavior.setValue(3, forKeyPath: "frequency")
        return behavior
    }
    
    // Simulate explosion effect; cells are emitted outwards in all directions from a single point
    private func attractorBehavior(for emitterLayer: CAEmitterLayer) -> Any {
        let behavior = createBehavior(type: "attractor")
        behavior.setValue("attractor", forKeyPath: "name")
        
        // Attractiveness
        behavior.setValue(-290, forKeyPath: "falloff")
        behavior.setValue(300, forKeyPath: "radius")
        behavior.setValue(10, forKeyPath: "stiffness")
        
        // Position
        let emitterPoint = CGPoint(x: emitterLayer.emitterPosition.x, y: emitterLayer.emitterPosition.y + 20)
        behavior.setValue(emitterPoint, forKeyPath: "position")
        behavior.setValue(-70, forKeyPath: "zPosition")
        return behavior
    }
    
    private func dragBehavior() -> Any {
        let behavior = createBehavior(type: "drag")
        behavior.setValue("drag", forKey: "name")
        behavior.setValue(2, forKey: "drag")
        return behavior
    }
    
    // Helper method
    private func createBehavior(type: String) -> NSObject {
        let behaviorClass = NSClassFromString("CAEmitterBehavior") as! NSObject.Type
        let behaviorWithType = behaviorClass.method(for: NSSelectorFromString("behaviorWithType:"))!
        let castedBehaviorWithType = unsafeBitCast(behaviorWithType, to:(@convention(c)(Any?, Selector, Any?) -> NSObject).self)
        return castedBehaviorWithType(behaviorClass, NSSelectorFromString("behaviorWithType:"), type)
    }
}


// MARK: - CAAnimations

extension ConfettiView {
    
    // Adjusts the attractor behavior's repulsive force over time, from initially strong to almost no force at all
    private func addAttractorAnimation(to layer: CALayer) {
        let animation = CAKeyframeAnimation()
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = 3
        animation.keyTimes = [0, 0.4]
        animation.values = [85, 5]
        layer.add(animation, forKey: "emitterBehaviors.attractor.stiffness")
    }
    
    // Emit lots of confetti at first, eventually decreasing emission rate down to zero
    private func addBirthrateAnimation(to layer: CALayer) {
        let animation = CAKeyframeAnimation()
        animation.duration = 1.5
        animation.keyTimes = [0.05, 0.45, 0.6]
        animation.values = [0.7, 1, 0]
        layer.add(animation, forKey: "birthRate")
    }
    
    // Animate the gravity starting it off low to accentuate the initial explosion
    private func addGravityAnimation(to layer: CALayer) {
        let animation = CAKeyframeAnimation()
        animation.duration = 4
        animation.keyTimes = [0.08, 0.16, 0.32, 0.65, 1]
        animation.values = [0, 200, 500, 2000, 4300]
        confettiTypes.forEach { layer.add(animation, forKey: "emitterCells.\($0.name).yAcceleration") }
    }
    
    private func addDragAnimation(to layer: CALayer) {
        let animation = CABasicAnimation()
        animation.duration = 0.35
        animation.fromValue = 0
        animation.toValue = 2
        layer.add(animation, forKey:  "emitterBehaviors.drag.drag")
    }
}


// MARK: - ConfettiType

extension ConfettiView {

    private enum ConfettiShape { case rectangle, circle }
    private enum ConfettiPosition { case foreground, background }

    private class ConfettiType {
        let color: UIColor
        let shape: ConfettiShape
        let position: ConfettiPosition
        
        init(color: UIColor, shape: ConfettiShape, position: ConfettiPosition) {
            self.color = color
            self.shape = shape
            self.position = position
        }
        
        var name = UUID().uuidString
        
        lazy var image: UIImage = {
            switch shape {
            
            case .rectangle:
                let imageRect = CGRect(x: 0, y: 0, width: 20, height: 13)
                UIGraphicsBeginImageContext(imageRect.size)
                let context = UIGraphicsGetCurrentContext()!
                context.setFillColor(color.cgColor)
                context.fill(imageRect)
                
            case .circle:
                let imageRect = CGRect(x: 0, y: 0, width: 10, height: 10)
                UIGraphicsBeginImageContext(imageRect.size)
                let context = UIGraphicsGetCurrentContext()!
                context.setFillColor(color.cgColor)
                context.fillEllipse(in: imageRect)
            }
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }()
    }
}
