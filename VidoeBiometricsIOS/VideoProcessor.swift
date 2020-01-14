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
            self.updateWaveform(lineChartView: parent!.lineChartsRaw, dataSeries: HeartRateSeries.rawData)
            self.updateWaveform(lineChartView: parent!.lineChartsFiltered, dataSeries: HeartRateSeries.filteredData)
            //            self.updateRawWaveform()
//            self.updateFilteredWaveform()
//            DispatchQueue.main.async {
//                    self.parent?.heartRateLabel = heartRateStr
//            }


//            DispatchQueue.main.async {
//                self.heartRateLabel.text = heartRateStr
//                self.rawDelegate?.dataReady()
//                self.fftDelegate?.dataReady()
//                self.filteredDelegate?.dataReady()
//                self.ICADelegate?.dataReady()
//                self.ICAFFTDelegate?.dataReady()
//            }
        }
    }
    func initialize( parent:ContentView){
        openCVWrapper.delegate = self
        heartRateCalculation = HeartRateCalculation( openCVWrapper )
        self.parent = parent
        openCVWrapper.initializeCamera(300)
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
    func calculateHeartRate() -> Double{
        return heartRateCalculation!.heartRateFrequency! * 60.0
    }
    func calculateHeartRateFromICA() -> Double{
        return heartRateCalculation!.heartRateFrequencyICA! * 60.0
    }

    func updateWaveform( lineChartView:LineCharts?, dataSeries:HeartRateSeries ){
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
                lineChart.chartDescription!.text = "Raw RGB data (Normalized)"
            }
        }
    }

//    func updateRawWaveform(){
//        if let timeSeries = heartRateCalculation!.timeSeries {
//            let data = LineChartData()
//            if let redData = heartRateCalculation!.normalizedRedAmplitude  {
//                addLine(data, redData, timeSeries, color:[NSUIColor.red], "Red")
//            }
//            if let greenData = heartRateCalculation!.normalizedGreenAmplitude  {
//                addLine(data, greenData, timeSeries, color:[NSUIColor.green], "Green")
//
//            }
//            if let blueData = heartRateCalculation!.normalizedBlueAmplitude  {
//                addLine(data, blueData, timeSeries, color:[NSUIColor.blue], "Blue")
//            }
//            parent!.lineChartsRaw.lineChart!.data = data
//            parent!.lineChartsRaw.lineChart!.chartDescription!.text = "Raw RGB data (Normalized)"
//        }
//    }
//
//    func updateFilteredWaveform(){
//        if let timeSeries = heartRateCalculation!.timeSeries {
//            let data = LineChartData()
//            if let redData = heartRateCalculation!.filteredRedAmplitude  {
//                addLine(data, redData, timeSeries, color:[NSUIColor.red], "Red")
//            }
//            if let greenData = heartRateCalculation!.filteredGreenAmplitude  {
//                addLine(data, greenData, timeSeries, color:[NSUIColor.green], "Green")
//
//            }
//            if let blueData = heartRateCalculation!.filteredBlueAmplitude  {
//                addLine(data, blueData, timeSeries, color:[NSUIColor.blue], "Blue")
//            }
//            parent!.lineChartsFiltered.lineChart!.data = data
//            parent!.lineChartsFiltered.lineChart!.chartDescription!.text = "Filtered RGB data (Normalized)"
//        }
//    }

    
    func addLine( _ lineChartData:LineChartData, _ yData:[Double], _ xData:[Double], color:[NSUIColor], _ name:String) {
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
    func getRDBdata( _ dataSeries:HeartRateSeries ) -> ([Double]?, [Double]?, [Double]?){
        let red:[Double]?
        let green:[Double]?
        let blue:[Double]?

        switch dataSeries {
        case .rawData:
            return (heartRateCalculation!.normalizedRedAmplitude, heartRateCalculation!.normalizedGreenAmplitude, heartRateCalculation!.normalizedBlueAmplitude)
        
        case .filteredData:
            return (heartRateCalculation!.filteredRedAmplitude, heartRateCalculation!.filteredGreenAmplitude, heartRateCalculation!.filteredBlueAmplitude)

        default:
            return (red, green, blue)
        }
    }
}
