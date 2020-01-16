//
//  SettingsView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/15/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI
import Charts

struct SettingsView : View {
//    @State var pauseBetweenSamples = false
    @State var dummy1 = "0.7"
    @State var dummy2 = "1.4"

    var parent:ContentView

    var body: some View {
        
        VStack {
            Toggle(isOn: parent.$userSettings.pauseBetweenSamples) {
               Text("Pause between samples")
            }
            .padding(EdgeInsets(top:0, leading: 10, bottom:0, trailing: 10 ))
            Spacer()
            HStack{
                Text("Bandpass filter frequencies (Hz)")
                    .padding( .leading, 10 )
                Spacer()
            }
            HStack {
                Text("From: ")
                TextField("Low Frequency", text: parent.$userSettings.filterStart)
                    .keyboardType(.decimalPad)
                Spacer()
                Text("To: ")
                TextField("High Frequency", text: parent.$userSettings.filterEnd)
                    .keyboardType(.decimalPad)
            }
            .padding(EdgeInsets(top:0, leading: 10, bottom:0, trailing: 10 ))
            SettingsChartView( parent:parent)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 300)
                    .onAppear(perform: updateChart)
        }
    }
    func updateChart(){
        parent.videoProcessor.updateFilteredChart()
    }
}

struct SettingsChartView: UIViewRepresentable {
    var parent:ContentView
    
    func updateUIView(_ lineChart: LineChartView, context: Context) {
        parent.lineChartsFiltered.setLineChart( lineChart )
    }
    
    func makeUIView(context: Context) -> LineChartView {
        return LineChartView()
    }

}
