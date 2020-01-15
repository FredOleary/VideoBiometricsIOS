//
//  VideoProcessor.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/13/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import Foundation
import Charts

enum CameraState {
    case stopped
    case running
    case paused
}
enum HeartRateSeries {
    case rawData
    case filteredData
    case fftData
}

class VideoProcessor: NSObject, OpenCVWrapperDelegate{
    
    var videoView:VideoView? = nil
    var parent:ContentView?
    var cameraRunning = CameraState.stopped;
    let openCVWrapper = OpenCVWrapper()
    var heartRateCalculation:HeartRateCalculation?

    func frameAvailable(_ frame: UIImage, _ heartRateProgress: Float, _ frameNumber: Int32) {
//        print("VideoDelegate:frameAvailable")
        videoView?.videoFrame = frame
        parent!.progressBarValue = CGFloat(heartRateProgress)
        self.parent!.frameNumberLabel = NSString(format: "Frame: %d", frameNumber) as String
        
    }
    
    func framesReady(_ videoProcessingPaused: Bool) {
        print("ViewController: framesReady videoProcessingPaused: ", videoProcessingPaused)
        if( videoProcessingPaused){
//            let pauseBetweenSamples = Settings.getPauseBetweenSamples()
            let pauseBetweenSamples = true
            if( pauseBetweenSamples ){
                self.cameraRunning = CameraState.paused
                self.parent?.startStopVideoButton = "Resume"

//                DispatchQueue.main.async {
//                        self.cameraRunning = CameraState.paused
//                        self.parent?.startStopVideoButton = "Resume"
//                }
            }else{
                openCVWrapper.resumeCamera();
            }
            heartRateCalculation!.calculateHeartRate()
            var heartRateStr:String = "Heart Rate: N/A"
            let hrFrequency = calculateHeartRate()
            if( hrFrequency > 0){
                let hrFrequencyICA = calculateHeartRateFromICA()
                heartRateStr = NSString(format: "Heart Rate %.1f/%.1f", hrFrequency, hrFrequencyICA) as String
            }
            self.parent?.heartRateLabel = heartRateStr
            self.updateRawChart()
            self.updateFilteredChart()
            self.updateFFTChart()
        }
    }
    func updateRawChart(){
        self.updateWaveform(lineChartView: parent!.lineChartsRaw, dataSeries: HeartRateSeries.rawData, "Raw RGB")
    }
    func updateFilteredChart(){
        self.updateWaveform(lineChartView: parent!.lineChartsFiltered, dataSeries: HeartRateSeries.filteredData, "Filtered RGB")
    }
    func updateFFTChart(){
        self.updateFFT(barChartView: parent!.barChartsFFT, dataSeries: HeartRateSeries.fftData, "FFT of filtered data")
    }
    func startStopCamera(){
        if( cameraRunning == CameraState.stopped ){
            cameraRunning = CameraState.running;
            openCVWrapper.startCamera();
            self.parent!.startStopVideoButton = "Stop"
        }else if( cameraRunning == CameraState.running ){
            cameraRunning = CameraState.stopped;
            openCVWrapper.stopCamera();
            self.parent!.startStopVideoButton = "Start"
        }else if( cameraRunning == CameraState.paused ){
            cameraRunning = CameraState.running;
            openCVWrapper.resumeCamera();
            self.parent!.startStopVideoButton = "Stop"
        }

    }
    func initialize( parent:ContentView){
        openCVWrapper.delegate = self
        heartRateCalculation = HeartRateCalculation( openCVWrapper )
        self.parent = parent
        openCVWrapper.initializeCamera(300)
    }

    private func calculateHeartRate() -> Double{
        return heartRateCalculation!.heartRateFrequency! * 60.0
    }
    private func calculateHeartRateFromICA() -> Double{
        return heartRateCalculation!.heartRateFrequencyICA! * 60.0
    }

    private func updateWaveform( lineChartView:LineCharts?, dataSeries:HeartRateSeries, _ description:String){
        if let lineChart = lineChartView?.lineChart {
            let (red, green, blue) = getRDBdata(dataSeries )
            
            if let timeSeries = heartRateCalculation!.timeSeries {
                let data = LineChartData()
                if let redData = red  {
                    addLine(data, redData, timeSeries, color:[NSUIColor.red], "Red")
                }
                if let greenData = green {
                    addLine(data, greenData, timeSeries, color:[NSUIColor.green], "Green")

                }
                if let blueData = blue {
                    addLine(data, blueData, timeSeries, color:[NSUIColor.blue], "Blue")
                }
                lineChart.data = data
                lineChart.chartDescription!.text = description
                lineChart.chartDescription!.font = .systemFont(ofSize: 16, weight: .light)
            }
        }
    }

    
    private func addLine( _ lineChartData:LineChartData, _ yData:[Double], _ xData:[Double], color:[NSUIColor], _ name:String) {
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        
        for i in 0..<yData.count {
            let value = ChartDataEntry(x: xData[i], y: yData[i])
            lineChartEntry.append(value) // here we add it to the data set
        }

        let line1 = LineChartDataSet(entries: lineChartEntry, label: name) //Here we convert lineChartEntry to a LineChartDataSet
        line1.drawCirclesEnabled = false
        line1.colors = color
        lineChartData.addDataSet(line1) //Adds the line to the dataSet

    }
    
    private func updateFFT( barChartView:BarCharts?, dataSeries:HeartRateSeries, _ description:String ){
        if let barChart = barChartView?.barChart {
            let (red, green, blue) = getRDBdata(dataSeries )
            
            if let timeSeries = heartRateCalculation!.FFTRedFrequency {
                if( timeSeries.count > 0){
                    let timeWidth = timeSeries[timeSeries.count-1] - timeSeries[0]; // total X time
                    let groupWidth = timeWidth/Double(timeSeries.count)
                    let groupSpace = groupWidth/4.0
                    let barSpace = groupWidth/8.0
                    let barWidth = groupWidth/8.0
                    // (barSpace + barWidth) * 3 + groupSpace= groupWidth

                    let data = BarChartData()
                    data.barWidth = barWidth

                    let redFreq = NSString(format: "Red BPM %.1f", (heartRateCalculation!.heartRateRedFrequency! * 60))
                    let greenFreq = NSString(format: "Green BPM %.1f", (heartRateCalculation!.heartRateGreenFrequency! * 60))
                    let blueFreq = NSString(format: "Blue BPM %.1f", (heartRateCalculation!.heartRateBlueFrequency! * 60))
                    
                    if let redData = red  {
                        addBar(data, redData, timeSeries, color:[NSUIColor.red], redFreq as String)
                    }
                    if let greenData = green {
                        addBar(data, greenData, timeSeries, color:[NSUIColor.green], greenFreq as String)
                    }
                    if let blueData = blue {
                        addBar(data, blueData, timeSeries, color:[NSUIColor.blue], blueFreq as String)
                    }

                    barChart.xAxis.axisMinimum = timeSeries[0];
                    barChart.xAxis.axisMaximum = timeSeries[timeSeries.count-1]
                    
                    data.groupBars(fromX: timeSeries[0], groupSpace:groupSpace, barSpace: barSpace)
                    data.setValueFont(.systemFont(ofSize: 0, weight: .light))
                    
                    barChart.data = data
                    barChart.chartDescription?.text = description
                    barChart.chartDescription?.font = .systemFont(ofSize: 16, weight: .light)
                    barChart.legend.font = .systemFont(ofSize: 16, weight: .light)
                }
           }
        }
    }

    private func addBar( _ barChartData:BarChartData, _ yData:[Double], _ xData:[Double], color:[NSUIColor], _ name:String) {
        var barChartEntry  = [BarChartDataEntry]()
        for i in 0..<yData.count {
            let value = BarChartDataEntry(x: xData[i], y: yData[i]) // here we set the X and Y status in a data chart entry
            barChartEntry.append(value)
        }

        let bar1 = BarChartDataSet(entries: barChartEntry, label: name)
        bar1.colors = color
        bar1.drawValuesEnabled = false
        barChartData.addDataSet(bar1)
    }

    private func getRDBdata( _ dataSeries:HeartRateSeries ) -> ([Double]?, [Double]?, [Double]?){
        let red:[Double]?
        let green:[Double]?
        let blue:[Double]?

        switch dataSeries {
        case .rawData:
            return (heartRateCalculation!.normalizedRedAmplitude, heartRateCalculation!.normalizedGreenAmplitude, heartRateCalculation!.normalizedBlueAmplitude)
        
        case .filteredData:
            return (heartRateCalculation!.filteredRedAmplitude, heartRateCalculation!.filteredGreenAmplitude, heartRateCalculation!.filteredBlueAmplitude)

        case .fftData:
            return (heartRateCalculation!.FFTRedAmplitude, heartRateCalculation!.FFTGreenAmplitude, heartRateCalculation!.FFTBlueAmplitude)

        default:
            return (red, green, blue)
        }
    }
}
