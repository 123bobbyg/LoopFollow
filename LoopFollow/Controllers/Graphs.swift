//
//  Graphs.swift
//  LoopFollow
//
//  Created by Jon Fawcett on 6/16/20.
//  Copyright © 2020 Jon Fawcett. All rights reserved.
//

import Foundation
import Charts
import UIKit


extension MainViewController {
    

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if chartView == BGChartFull {
            BGChart.moveViewToX(entry.x)
        }
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        if chartView == BGChart {
            let currentMatrix = chartView.viewPortHandler.touchMatrix
            //BGChartFull.viewPortHandler.refresh(newMatrix: currentMatrix, chart: BGChartFull, invalidate: true)
            //BGChartFull.highlightValue(x: Double(currentMatrix.tx), y: Double(currentMatrix.ty), dataSetIndex: 0)
        }
    }

    // data.addDataSet(lineBG) // Dataset 0
    // data.addDataSet(lineBasal) // Dataset 1
    // data.addDataSet(lineBolus) // Dataset 2
    // data.addDataSet(lineCarbs) // Dataset 3
    func createGraph(){
        self.BGChart.clear()
        // Create the BG Graph Data
        let entries = bgData
        var bgChartEntry = [ChartDataEntry]()
        var colors = [NSUIColor]()
        var maxBG: Float = UserDefaultsRepository.minBGScale.value
        
        // Setup BG line details
        let lineBG = LineChartDataSet(entries:bgChartEntry, label: "")
        lineBG.circleRadius = 3
        lineBG.circleColors = [NSUIColor.systemGreen]
        lineBG.drawCircleHoleEnabled = false
        lineBG.axisDependency = YAxis.AxisDependency.right
        lineBG.highlightEnabled = false
        lineBG.drawValuesEnabled = false
        
        if UserDefaultsRepository.showLines.value {
            lineBG.lineWidth = 2
        } else {
            lineBG.lineWidth = 0
        }
        if UserDefaultsRepository.showDots.value {
            lineBG.drawCirclesEnabled = true
        } else {
            lineBG.drawCirclesEnabled = false
        }
        lineBG.setDrawHighlightIndicators(false)
        lineBG.valueFont.withSize(50)
        
        

        // create Basal graph data
        var chartEntry = [ChartDataEntry]()
        var maxBasal = UserDefaultsRepository.minBasalScale.value
        let lineBasal = LineChartDataSet(entries:chartEntry, label: "")
        lineBasal.setDrawHighlightIndicators(false)
        lineBasal.setColor(NSUIColor.systemBlue, alpha: 0.5)
        lineBasal.lineWidth = 0
        lineBasal.drawFilledEnabled = true
        lineBasal.fillColor = NSUIColor.systemBlue.withAlphaComponent(0.8)
        lineBasal.drawCirclesEnabled = false
        lineBasal.axisDependency = YAxis.AxisDependency.left
        lineBasal.highlightEnabled = false
        lineBasal.drawValuesEnabled = false
        
        // Boluses
        var chartEntryBolus = [ChartDataEntry]()
        let lineBolus = LineChartDataSet(entries:chartEntryBolus, label: "")
        lineBolus.circleRadius = 7
        lineBolus.circleColors = [NSUIColor.systemBlue.withAlphaComponent(0.75)]
        lineBolus.drawCircleHoleEnabled = false
        lineBolus.setDrawHighlightIndicators(false)
        lineBolus.setColor(NSUIColor.systemBlue, alpha: 1.0)
        lineBolus.drawCirclesEnabled = true
        lineBolus.lineWidth = 0
        lineBolus.axisDependency = YAxis.AxisDependency.right
        lineBolus.valueFormatter = ChartYDataValueFormatter()
        lineBolus.drawValuesEnabled = true
        lineBolus.valueTextColor = NSUIColor.label

        
        // Carbs
        var chartEntryCarbs = [ChartDataEntry]()
        let lineCarbs = LineChartDataSet(entries:chartEntryCarbs, label: "")
        lineCarbs.circleRadius = 7
        lineCarbs.circleColors = [NSUIColor.systemOrange.withAlphaComponent(0.75)]
        lineCarbs.drawCircleHoleEnabled = false
        lineCarbs.setDrawHighlightIndicators(false)
        lineCarbs.setColor(NSUIColor.systemBlue, alpha: 1.0)
        lineCarbs.drawCirclesEnabled = true
        lineCarbs.lineWidth = 0
        lineCarbs.axisDependency = YAxis.AxisDependency.right
        lineCarbs.valueFormatter = ChartYDataValueFormatter()
        lineCarbs.drawValuesEnabled = true
        lineCarbs.valueTextColor = NSUIColor.label
        
        // Setup the chart data of all lines
        let data = LineChartData()
        data.addDataSet(lineBG) // Dataset 0
        data.addDataSet(lineBasal) // Dataset 1
        data.addDataSet(lineBolus) // Dataset 2
        data.addDataSet(lineCarbs) // Dataset 3
        data.setValueFont(UIFont.systemFont(ofSize: 12))
        
        // Clear limit lines so they don't add multiples when changing the settings
        BGChart.rightAxis.removeAllLimitLines()
        
        //Add lower red line based on low alert value
        let ll = ChartLimitLine()
        ll.limit = Double(UserDefaultsRepository.lowLine.value)
        ll.lineColor = NSUIColor.systemRed.withAlphaComponent(0.5)
        BGChart.rightAxis.addLimitLine(ll)
        
        //Add upper yellow line based on low alert value
        let ul = ChartLimitLine()
        ul.limit = Double(UserDefaultsRepository.highLine.value)
        ul.lineColor = NSUIColor.systemYellow.withAlphaComponent(0.5)
        BGChart.rightAxis.addLimitLine(ul)
        
        // Setup the main graph overall details
        BGChart.xAxis.valueFormatter = ChartXValueFormatter()
        BGChart.xAxis.granularity = 1800
        BGChart.xAxis.labelTextColor = NSUIColor.label
        BGChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        BGChart.xAxis.drawGridLinesEnabled = false
        
        BGChart.leftAxis.enabled = true
        BGChart.leftAxis.labelPosition = YAxis.LabelPosition.insideChart
        BGChart.leftAxis.axisMaximum = maxBasal
        BGChart.leftAxis.axisMinimum = 0.0
        BGChart.leftAxis.drawGridLinesEnabled = false
        
        BGChart.rightAxis.labelTextColor = NSUIColor.label
        BGChart.rightAxis.labelPosition = YAxis.LabelPosition.insideChart
        BGChart.rightAxis.axisMinimum = 40
        BGChart.rightAxis.axisMaximum = Double(maxBG)
        BGChart.rightAxis.gridLineDashLengths = [5.0, 5.0]
        BGChart.rightAxis.valueFormatter = ChartYMMOLValueFormatter()
        
        BGChart.legend.enabled = false
        BGChart.scaleYEnabled = false
        BGChart.drawGridBackgroundEnabled = false
        //BGChart.gridBackgroundColor = NSUIColor.secondarySystemBackground
        
        BGChart.data = data
        BGChart.setExtraOffsets(left: 10, top: 10, right: 10, bottom: 10)
        BGChart.setVisibleXRangeMinimum(10)
       
        
    }
    
    func updateBGGraphSettings() {
        let dataIndex = 0
        let lineBG = BGChart.lineData!.dataSets[dataIndex] as! LineChartDataSet
        if UserDefaultsRepository.showLines.value {
                   lineBG.lineWidth = 2
               } else {
                   lineBG.lineWidth = 0
               }
               if UserDefaultsRepository.showDots.value {
                   lineBG.drawCirclesEnabled = true
               } else {
                   lineBG.drawCirclesEnabled = false
               }
        
        // Clear limit lines so they don't add multiples when changing the settings
        BGChart.rightAxis.removeAllLimitLines()
        
        //Add lower red line based on low alert value
        let ll = ChartLimitLine()
        ll.limit = Double(UserDefaultsRepository.lowLine.value)
        ll.lineColor = NSUIColor.systemRed.withAlphaComponent(0.5)
        BGChart.rightAxis.addLimitLine(ll)
        
        //Add upper yellow line based on low alert value
        let ul = ChartLimitLine()
        ul.limit = Double(UserDefaultsRepository.highLine.value)
        ul.lineColor = NSUIColor.systemYellow.withAlphaComponent(0.5)
        BGChart.rightAxis.addLimitLine(ul)
        
        BGChart.data?.dataSets[dataIndex].notifyDataSetChanged()
        BGChart.data?.notifyDataChanged()
        BGChart.notifyDataSetChanged()
        
    }
    
    func updateBGGraph() {
        let dataIndex = 0
        let entries = bgData
        var mainChart = BGChart.lineData!.dataSets[dataIndex] as! LineChartDataSet
        var smallChart = BGChartFull.lineData!.dataSets[dataIndex] as! LineChartDataSet
        mainChart.clear()
        smallChart.clear()
        var maxBG = UserDefaultsRepository.minBGScale.value
        var maxBGOffset: Float = 0.0
        if UserDefaultsRepository.offsetCarbsBolus.value {
            maxBGOffset = 40.0
        }
        var colors = [NSUIColor]()
        for i in 0..<entries.count{
            if Float(entries[i].sgv) > maxBG - maxBGOffset {
                maxBG = Float(entries[i].sgv) + maxBGOffset
            }
            let value = ChartDataEntry(x: Double(entries[i].date), y: Double(entries[i].sgv))
            mainChart.addEntry(value)
            smallChart.addEntry(value)
            
            if Double(entries[i].sgv) >= Double(UserDefaultsRepository.highLine.value) {
                colors.append(NSUIColor.systemYellow)
            } else if Double(entries[i].sgv) <= Double(UserDefaultsRepository.lowLine.value) {
               colors.append(NSUIColor.systemRed)
            } else {
                colors.append(NSUIColor.systemGreen)
            }
        }
        
        // Add Prediction Data
        if predictionData.count > 0 && bgData.count > 0 && UserDefaultsRepository.graphPrediction.value {
            if UserDefaultsRepository.debugLog.value { self.writeDebugLog(value: "Graph: print prediction") }
            var startingTime = entries[entries.count - 1].date + 300
            if latestLoopTime < dateTimeUtils.getNowTimeIntervalUTC() - 300 {
               startingTime = latestLoopTime + 300
            }
            var i = 0
            // Add 1 hour of predictions
            while i < 12 {
                var predictionVal = Double(predictionData[i])
                // Below can be turned on to prevent out of range on the graph if desired.
                // It currently just drops them out of view
                if predictionVal > 400 {
               //     predictionVal = 400
                } else if predictionVal < 0 {
                //    predictionVal = 0
                }
                let value = ChartDataEntry(x: startingTime + 5, y: predictionVal)
                mainChart.addEntry(value)
                smallChart.addEntry(value)
                colors.append(NSUIColor.systemPurple)
                startingTime += 300
                i += 1
            }
        }
        
        // Set Colors
        let lineBG = BGChart.lineData!.dataSets[dataIndex] as! LineChartDataSet

        let lineBGSmall = BGChartFull.lineData!.dataSets[dataIndex] as! LineChartDataSet
        lineBG.colors.removeAll()
        lineBG.circleColors.removeAll()
        lineBGSmall.colors.removeAll()
        lineBGSmall.circleColors.removeAll()

        if colors.count > 0 {
            if UserDefaultsRepository.debugLog.value { self.writeDebugLog(value: "Graph: colors") }
            for i in 0..<colors.count{
                mainChart.addColor(colors[i])
                mainChart.circleColors.append(colors[i])
                smallChart.addColor(colors[i])
                smallChart.circleColors.append(colors[i])
            }
        }
        
        BGChart.rightAxis.axisMaximum = Double(maxBG)
       
        
        BGChart.data?.dataSets[dataIndex].notifyDataSetChanged()
        BGChart.data?.notifyDataChanged()
        BGChart.notifyDataSetChanged()
        BGChartFull.data?.dataSets[dataIndex].notifyDataSetChanged()
        BGChartFull.data?.notifyDataChanged()
        BGChartFull.notifyDataSetChanged()
        
        if firstGraphLoad {
            BGChart.zoom(scaleX: 18, scaleY: 1, x: 1, y: 1)
            firstGraphLoad = false
        }
        if BGChart.chartXMax > dateTimeUtils.getNowTimeIntervalUTC() {
            BGChart.moveViewToAnimated(xValue: dateTimeUtils.getNowTimeIntervalUTC() - (BGChart.visibleXRange * 0.7), yValue: 0.0, axis: .right, duration: 1, easingOption: .easeInBack)
        }
    }
    
    func updateBasalGraph() {
        var dataIndex = 1
        BGChart.lineData?.dataSets[dataIndex].clear()
        var maxBasal = UserDefaultsRepository.minBasalScale.value
        for i in 0..<basalData.count{
            let value = ChartDataEntry(x: Double(basalData[i].date), y: Double(basalData[i].basalRate))
            BGChart.data?.dataSets[dataIndex].addEntry(value)
            if basalData[i].basalRate  > maxBasal {
                maxBasal = basalData[i].basalRate
            }
        }
        
        BGChart.leftAxis.axisMaximum = maxBasal
        
        BGChart.data?.dataSets[dataIndex].notifyDataSetChanged()
        BGChart.data?.notifyDataChanged()
        BGChart.notifyDataSetChanged()
    }
    
    func updateBolusGraph() {
        var dataIndex = 2
        BGChart.lineData?.dataSets[dataIndex].clear()
        for i in 0..<bolusData.count{
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.minimumIntegerDigits = 1
            var offset = 0
            if UserDefaultsRepository.offsetCarbsBolus.value {
                offset = 10
            }
            let value = ChartDataEntry(x: Double(bolusData[i].date), y: Double(bolusData[i].sgv + offset), data: formatter.string(from: NSNumber(value: bolusData[i].value)))
            BGChart.data?.dataSets[dataIndex].addEntry(value)

        }
        
        BGChart.data?.dataSets[dataIndex].notifyDataSetChanged()
        BGChart.data?.notifyDataChanged()
        BGChart.notifyDataSetChanged()
    }
    
    func updateCarbGraph() {
        var dataIndex = 3
        BGChart.lineData?.dataSets[dataIndex].clear()
        for i in 0..<carbData.count{
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.minimumIntegerDigits = 1
            var offset = 0
            if UserDefaultsRepository.offsetCarbsBolus.value {
                offset = 30
            }
             let value = ChartDataEntry(x: Double(carbData[i].date), y: Double(carbData[i].sgv + offset), data: formatter.string(from: NSNumber(value: carbData[i].value)))
            BGChart.data?.dataSets[dataIndex].addEntry(value)

        }
        
        BGChart.data?.dataSets[dataIndex].notifyDataSetChanged()
        BGChart.data?.notifyDataChanged()
        BGChart.notifyDataSetChanged()
    }
    
 
    
    func createSmallBGGraph(){
        let entries = bgData
       var bgChartEntry = [ChartDataEntry]()
       var colors = [NSUIColor]()
        
        
        let lineBG = LineChartDataSet(entries:bgChartEntry, label: "")
        
        lineBG.drawCirclesEnabled = false
        //line2.setDrawHighlightIndicators(false)
        lineBG.highlightEnabled = true
        lineBG.drawHorizontalHighlightIndicatorEnabled = false
        lineBG.drawVerticalHighlightIndicatorEnabled = false
        lineBG.highlightColor = NSUIColor.label
        lineBG.drawValuesEnabled = false
        lineBG.lineWidth = 2

        let data2 = LineChartData()
        data2.addDataSet(lineBG)
        BGChartFull.highlightPerDragEnabled = true
        BGChartFull.leftAxis.enabled = false
        BGChartFull.rightAxis.enabled = false
        BGChartFull.xAxis.enabled = false
        BGChartFull.legend.enabled = false
        BGChartFull.scaleYEnabled = false
        BGChartFull.scaleXEnabled = false
        BGChartFull.drawGridBackgroundEnabled = false
        BGChartFull.data = data2
    }
    
  
}
