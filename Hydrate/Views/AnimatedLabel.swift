//
//  AnimatedLabel.swift
//  Hydrate
//
//  Created by David Wright on 9/23/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class AnimatedLabel: UILabel {
    enum CountingMethod {
        case easeInOut, easeIn, easeOut, linear
    }
    
    var countingMethod: CountingMethod = .easeInOut
    
    private var currentValue: Float {
        if progress >= totalTime { return destinationValue }
        return startingValue + (update(t: Float(progress / totalTime)) * (destinationValue - startingValue))
    }
    
    private var rate: Float = 0
    private var startingValue: Float = 0
    private var destinationValue: Float = 0
    private var progress: TimeInterval = 0
    private var lastUpdate: TimeInterval = 0
    private var totalTime: TimeInterval = 0
    private var easingRate: Float = 0
    private var timer: CADisplayLink?
    private var animationDuration: TimeInterval = 2.0
    
    func count(from: Float, to: Float, duration: TimeInterval = 8.0) {
        startingValue = from
        destinationValue = to
        timer?.invalidate()
        timer = nil
        
        if duration == 0.0 {
            setTextValue(value: to)
            return
        }
        
        easingRate = 3.0
        progress = 0.0
        totalTime = duration
        lastUpdate = Date.timeIntervalSinceReferenceDate
        rate = 3.0
        
        addDisplayLink()
    }
    
    func countFromCurrent(to: Float, duration: TimeInterval = 8.0) {
        count(from: currentValue, to: to, duration: duration)
    }
    
    func countFromZero(to: Float, duration: TimeInterval = 8.0) {
        count(from: 0, to: to, duration: duration)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        progress = totalTime
    }
    
    private func addDisplayLink() {
        timer = CADisplayLink(target: self, selector: #selector(self.updateValue(timer:)))
        timer?.add(to: .main, forMode: .default)
        timer?.add(to: .main, forMode: .tracking)
    }
    
    private func update(t: Float) -> Float {
        var t = t
        
        switch countingMethod {
        case .linear:
            return t
        case .easeIn:
            return powf(t, rate)
        case .easeInOut:
            var sign: Float = 1
            if Int(rate) % 2 == 0 { sign = -1 }
            t *= 2
            return t < 1 ? 0.5 * powf(t, rate) : (sign*0.5) * (powf(t-2, rate) + sign*2)
        case .easeOut:
            return 1.0-powf((1.0-t), rate);
        }
    }
    
    @objc private func updateValue(timer: Timer) {
        let now: TimeInterval = Date.timeIntervalSinceReferenceDate
        progress += now - lastUpdate
        lastUpdate = now
        
        if progress >= totalTime {
            self.timer?.invalidate()
            self.timer = nil
            progress = totalTime
        }
        
        setTextValue(value: currentValue)
    }
    
    private func setTextValue(value: Float) {
        text = "\(Int(value)) oz."
    }
}

