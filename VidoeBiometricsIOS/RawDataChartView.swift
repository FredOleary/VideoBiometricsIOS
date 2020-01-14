//
//  RawDataChartView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/10/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI
import Charts

struct RawDataChartView : View {
    var parent:ContentView

    var body: some View {
        RawChartView( parent:parent)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct RawChartView: UIViewRepresentable {
    var parent:ContentView
    
    func updateUIView(_ lineChart: LineChartView, context: Context) {
        lineChart.chartDescription?.text = "Raw RGB data"
//        lineChart.backgroundColor = UIColor.green
        parent.lineChartsRaw.setLineChart( lineChart )
    }
    
    func makeUIView(context: Context) -> LineChartView {
        return LineChartView()
    }

}

