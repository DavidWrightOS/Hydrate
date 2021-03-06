//
//  ChartView.swift
//  Hydrate
//
//  Created by David Wright on 2/28/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import UIKit
import CareKitUI

protocol ChartViewDataSource: class {
    var chartValues: [CGFloat] { get }
}

protocol ChartViewDelegate: class {
    var chartTitle: String? { get }
    var chartSubtitle: String? { get }
    var chartUnitTitle: String? { get }
    var chartHorizontalAxisMarkers: [String]? { get }
}

class ChartView: UIView {
    
    // MARK: - Properties
    
    var barWidth: CGFloat?
    
    private var chartInsetX: CGFloat = 20
    private var chartInsetY: CGFloat = 0
    
    weak var dataSource: ChartViewDataSource?
    weak var delegate: ChartViewDelegate?
    
    private var title: String? { delegate?.chartTitle }
    private var subtitle: String? { delegate?.chartSubtitle }
    private var unitDisplayName: String? { delegate?.chartUnitTitle }
    private var horizontalAxisMarkers: [String]? { delegate?.chartHorizontalAxisMarkers }
    
    private var chartView: OCKCartesianChartView = {
        let chartView = OCKCartesianChartView(type: .bar)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        return chartView
    }()
    
    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .backgroundColor
        tintColor = .actionColor
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        
        applyAlternateColorStyle()
        
        addSubview(chartView)
        
        let leading = chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: chartInsetX)
        let top = chartView.topAnchor.constraint(equalTo: topAnchor, constant: chartInsetY)
        let trailing = chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -chartInsetX)
        let bottom = chartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -chartInsetY)
        
        trailing.priority -= 1
        bottom.priority -= 1
        
        NSLayoutConstraint.activate([leading, top, trailing, bottom])
    }
    
    // MARK: - Update UI
    
    func reloadChart() {
        let values = dataSource?.chartValues ?? []
        
        // Update headerView
        chartView.headerView.titleLabel.text = delegate?.chartTitle
        chartView.headerView.detailLabel.text = delegate?.chartSubtitle
        
        // Update graphView
        let horizontalAxisMarkers = delegate?.chartHorizontalAxisMarkers ?? Array(repeating: "", count: values.count)
        chartView.graphView.horizontalAxisMarkers = horizontalAxisMarkers
        
        // Update graphView dataSeries
        let unitTitle = delegate?.chartUnitTitle ?? ""
        var ockDataSeries = OCKDataSeries(values: values, title: unitTitle)
        
        if let barWidth = barWidth {
            ockDataSeries.size = barWidth
        }
    
        chartView.graphView.dataSeries = [ockDataSeries]
    }
}


// MARK: - Custom Color Style

extension ChartView {
    
    /// Apply alternate color configuration to set axes and style in a custom configuration.
    private func applyAlternateColorStyle() {
        chartView.customStyle = CustomStyle()
        chartView.tintColor = tintColor
        chartView.headerView.detailLabel.textColor = .undeadWhite65
        chartView.graphView.numberFormatter = Format.numberFormatterRoundingToZeroDecimals
        chartView.graphView.yMinimum = 0
    }
    
    /// A styler using a custom color configuration
    struct CustomStyle: OCKStyler {
        var color: OCKColorStyler { CustomColors() }
        var appearance: OCKAppearanceStyler { NoShadowAppearanceStyle() }
    }
    
    struct CustomColors: OCKColorStyler {
        var secondaryCustomGroupedBackground: UIColor { .backgroundColor } // chart background color
        var label: UIColor { .undeadWhite } // chart title and horizontal axis label color
    }
    
    struct NoShadowAppearanceStyle: OCKAppearanceStyler {
        var shadowOpacity1: Float = 0
        var shadowRadius1: CGFloat = 0
        var shadowOffset1: CGSize = .zero
    }
}
