//
//  SettingsView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/15/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI
import Charts
class FrequencyChartHolder{
    var combinedChartView:CombinedChartView?
}

struct SettingsView : View {

    var parent:ContentView
    var frequencyChartHolder = FrequencyChartHolder()
    let startFrequency:Double = 15/60
    let endFrequency:Double = 600/60

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
            SettingsChartView( parent:self.frequencyChartHolder)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 300)
                    .onAppear(perform: updateChart)
        }
    }
    private func updateChart(){
        let temporalFilter: TemporalFilter = TemporalFilter()
        let (filterResponse, freqs) = temporalFilter.getFilterResponse(
            fps: 30.0,
            filterStart: Settings.getFilterStart(),
            filterEnd: Settings.getFilterEnd(),
            startFrequency: startFrequency,
            endFrequency: endFrequency )
        
        let data = CombinedChartData()
        addLine(data, filterResponse, freqs, color:[NSUIColor.black], "RMS filter frequency response")
        addFilterBars( data, Settings.getFilterStart(), Settings.getFilterEnd() )
        
        frequencyChartHolder.combinedChartView!.data = data
        frequencyChartHolder.combinedChartView!.chartDescription?.text = "Filter response)"
    }
    private func addLine( _ chartData:CombinedChartData, _ yData:[Double], _ xData:[Double], color:[NSUIColor], _ name:String) {
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        
        for i in 0..<yData.count {
            let value = ChartDataEntry(x: xData[i], y: yData[i])
            lineChartEntry.append(value) // here we add it to the data set
        }

        let line1 = LineChartDataSet(entries: lineChartEntry, label: name) //Here we convert lineChartEntry to a LineChartDataSet
        line1.drawCirclesEnabled = false
        line1.drawValuesEnabled = false
        line1.colors = color
        chartData.lineData = LineChartData(dataSet: line1)
    }
    private func addFilterBars( _ chartData:CombinedChartData, _ filterStart:Double, _ filterEnd:Double ) {
        let start = BarChartDataEntry(x: filterStart, y: 1.0)
        let end = BarChartDataEntry(x: filterEnd, y: 1.0)
        let filterBars:[BarChartDataEntry] = [start, end]
        
        let set = BarChartDataSet(entries: filterBars, label: "Filter band")
        set.setColor(NSUIColor.red)

        let data = BarChartData(dataSets: [set])
        data.barWidth = 0.05
        chartData.barData = data
    }

}

struct SettingsChartView: UIViewRepresentable {
    var parent:FrequencyChartHolder
    
    func updateUIView(_ combinedChartView: CombinedChartView, context: Context) {
        parent.combinedChartView = combinedChartView
    }
    
    func makeUIView(context: Context) -> CombinedChartView {
        return CombinedChartView()
    }

}
