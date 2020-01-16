//
//  FilteredICADataChartView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/16/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI
import Charts

struct FilteredICADataChartView : View {
    var parent:ContentView

    var body: some View {
        FilteredICAChartView( parent:parent)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .onAppear(perform: updateChart)
    }
    func updateChart(){
        parent.videoProcessor.updateFilteredICAChart()
    }
}

struct FilteredICAChartView: UIViewRepresentable {
    var parent:ContentView
    
    func updateUIView(_ lineChart: LineChartView, context: Context) {
        parent.lineChartsFilteredICA.setLineChart( lineChart )
    }
    
    func makeUIView(context: Context) -> LineChartView {
        return LineChartView()
    }

}
