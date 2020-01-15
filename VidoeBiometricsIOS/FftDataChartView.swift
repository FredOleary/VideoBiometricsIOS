//
//  FftDataChartView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/14/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI
import Charts

struct FftDataChartView : View {
    var parent:ContentView

    var body: some View {
        FftChartView( parent:parent)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .onAppear(perform: updateChart)
    }
    func updateChart(){
        parent.videoProcessor.updateFFTChart()
    }
}

struct FftChartView: UIViewRepresentable {
    var parent:ContentView
    
    func updateUIView(_ barChart: BarChartView, context: Context) {
        barChart.chartDescription?.text = "FFT RGB data"
        parent.barChartsFFT.setBarChart( barChart )
    }
    
    func makeUIView(context: Context) -> BarChartView {
        return BarChartView()
    }

}
