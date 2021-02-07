//
//  ChartView.swift
//  Hydrate
//
//  Created by David Wright on 1/25/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import SwiftUI

struct ChartView: View {
    
    let dailyLogController: DailyLogController
    var dailyLogs: [DailyLog] = []
    var dayOfWeekLabels = [String]()
    var totalsToChart = [Int]()

    init(dailyLogController: DailyLogController) {
        self.dailyLogController = dailyLogController
        updateDailyLogs()
    }
    
    var body: some View {
        ZStack {
            Color(.ravenClawBlue)
            VStack (alignment: .leading) {
                VStack (alignment: .leading, spacing: 0){
                    Text("Water Intake")
                        .font(.system(size:24))
                        .fontWeight(.heavy)
                        .foregroundColor(Color(UIColor.undeadWhite))
                    Text("Last Seven Days")
                        .foregroundColor(Color(UIColor.undeadWhite65))
                }
                
                HStack (spacing: 16) {
                    BarView(value: CGFloat(totalsToChart[0]), label: dayOfWeekLabels[0])
                    BarView(value: CGFloat(totalsToChart[1]), label: dayOfWeekLabels[1])
                    BarView(value: CGFloat(totalsToChart[2]), label: dayOfWeekLabels[2])
                    BarView(value: CGFloat(totalsToChart[3]), label: dayOfWeekLabels[3])
                    BarView(value: CGFloat(totalsToChart[4]), label: dayOfWeekLabels[4])
                    BarView(value: CGFloat(totalsToChart[5]), label: dayOfWeekLabels[5])
                    BarView(value: CGFloat(totalsToChart[6]), label: dayOfWeekLabels[6])
                }.padding(.top, 0)
                    .animation(.default)
            }
            
        }
    }
}

// MARK: - BarView
struct BarView: View {
    var value: CGFloat = 0
    var label: String = ""
    
    var body: some View {
        VStack {
            ZStack (alignment: .bottom) {
                Capsule().frame(width: 30, height: 125)
                    .foregroundColor(Color(UIColor.ravenClawBlue90))
                Capsule().frame(width: 30, height: value)
                    .foregroundColor(Color(UIColor.sicklySmurfBlue))
            }
            Text(label).padding(.top, 0)
                .foregroundColor(Color(UIColor.undeadWhite65))
                .font(.system(size: 15, weight: .medium, design: .default))
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(dailyLogController: DailyLogController())
    }
}

// MARK: - Extension
extension ChartView {
    
    mutating func updateDailyLogs() {
        let lastSevenDailyLogs = Array(dailyLogs.suffix(7))
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "M/d"
        let calendar = Calendar.current
        let today = Date().startOfDay
        
        dayOfWeekLabels = []
        totalsToChart = []
        
        for dayOffset in -6...0 {
            let day = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            dayOfWeekLabels.append(dayOfWeekFormatter.string(from: day))
            
            let dailyLog = lastSevenDailyLogs.first(where: { $0.date == day })
            let total = Int(dailyLog?.totalIntake ?? 0)
            totalsToChart.append(total)
        }
    }
}
