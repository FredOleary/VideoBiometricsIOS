//
//  FftICADataChartView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/16/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI
import Charts

struct FftICADataChartView : View {
    var parent:ContentView

    var body: some View {
        FftICAChartView( parent:parent)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .onAppear(perform: updateChart)
    }
    func updateChart(){
        parent.videoProcessor.updateFFTICAChart()
    }
}

struct FftICAChartView: UIViewRepresentable {
    var parent:ContentView
    
    func updateUIView(_ barChart: BarChartView, context: Context) {
        parent.barChartsFFTICA.setBarChart( barChart )
    }
    
    func makeUIView(context: Context) -> BarChartView {
        return BarChartView()
    }

}
