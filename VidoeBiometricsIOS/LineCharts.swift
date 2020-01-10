//
//  LineCharts.swift
//  
//
//  Created by Fred OLeary on 1/10/20.
//

import Foundation
import Charts

class LineCharts {
    var lineChart:LineChartView?
    
    func setLineChart( _ lineChart:LineChartView ){
        self.lineChart = lineChart
    }
    func updateChart(){
        let dollars1 = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        // 1 - creating an array of data entries
        var yValues : [ChartDataEntry] = [ChartDataEntry]()

        for i in 0 ..< months.count {
            yValues.append(ChartDataEntry(x: Double(i + 1), y: dollars1[i]))
        }

        let data = LineChartData()
        let ds = LineChartDataSet(entries: yValues, label: "Months")

        data.addDataSet(ds)
        lineChart!.data = data

    }
}
