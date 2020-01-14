//
//  FilteredDataChartView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/10/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI
import Charts

struct FilteredDataChartView : View {
    var parent:ContentView

    var body: some View {
        FilteredChartView( parent:parent)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct FilteredChartView: UIViewRepresentable {
    var parent:ContentView
    
    func updateUIView(_ lineChart: LineChartView, context: Context) {
        lineChart.chartDescription?.text = "Filtered RGB data"
//        lineChart.backgroundColor = UIColor.green
        parent.lineChartsFiltered.setLineChart( lineChart )
    }
    
    func makeUIView(context: Context) -> LineChartView {
        return LineChartView()
    }

}
