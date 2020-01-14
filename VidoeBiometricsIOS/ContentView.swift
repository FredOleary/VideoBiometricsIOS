//
//  ContentView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/7/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI
import Charts

class VideoDelegate: NSObject, OpenCVWrapperDelegate{
    
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
            self.updateRawWaveform()
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

    func updateRawWaveform(){
        if let timeSeries = heartRateCalculation!.timeSeries {
            let data = LineChartData()
            if let redData = heartRateCalculation!.normalizedRedAmplitude  {
                addLine(data, redData, timeSeries, color:[NSUIColor.red], "Red")
            }
            if let greenData = heartRateCalculation!.normalizedGreenAmplitude  {
                addLine(data, greenData, timeSeries, color:[NSUIColor.green], "Green")

            }
            if let blueData = heartRateCalculation!.normalizedBlueAmplitude  {
                addLine(data, blueData, timeSeries, color:[NSUIColor.blue], "Blue")
            }
            parent!.lineChartsRaw.lineChart!.data = data
            parent!.lineChartsRaw.lineChart!.chartDescription!.text = "Raw RGB data (Normalized)"
        }
    }
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
}




struct ContentView: View {
//    let openCVWrapper:OpenCVWrapper = OpenCVWrapper()
//    var heartRateCalculation:HeartRateCalculation
    
    @State var showVideo = true
    @State var showRaw = false
    @State var showFiltered = false
    @State var startStopVideoButton = "Start"
    @State var heartRateLabel = "Heart Rate: N/A"
    @State var progressBarValue:CGFloat = 0
    @State var frameNumberLabel = "Frame: "

    var lineChartsRaw = LineCharts()
    let videoDelegate = VideoDelegate()
    
//    init(){
//        openCVWrapper.delegate = videoDelegate
//        heartRateCalculation = HeartRateCalculation( openCVWrapper )
//    }
    
    var body: some View {
        VStack{
            HStack( spacing: 20){
                Button(action: {
                    self.showVideo = true
                    self.showRaw = false
                    self.showFiltered = false
                }) {
                    ButtonImage(imageAsset:"Video-camera")
//                    Image("Video-camera")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 32.0,height:32.0)
                }
                .padding(.leading, 10)
                Spacer()
                Button(action: {
                    self.showVideo = false
                    self.showRaw = true
                    self.showFiltered = false
                }) {
                    ButtonImage(imageAsset:"Raw-waveform")

                }
                Spacer()
                Button(action: {
                    self.showVideo = false
                    self.showRaw = false
                    self.showFiltered = true
                }) {
                    ButtonImage(imageAsset:"Filtered-waveform")

                }
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                    Text("FFT")
                }
            }
            HStack{
                Text(frameNumberLabel).padding(.leading)
                Spacer()
                Text(heartRateLabel).padding(.trailing)
            }
            .padding(.top)
            ProgressBar(value: $progressBarValue).frame(height:10)
//            Button(action: {
//                self.videoDelegate.startStopCamera()
//            }) {
//                Text(startStopVideoButton)
//            }
            Button(action: {
                self.videoDelegate.startStopCamera()
            }) {
                Text(startStopVideoButton)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(10)
                .font(Font.system(size: 36))
            }
            .background(Color.blue)
            .foregroundColor(.white)

            if showVideo {
                VideoView(bgColor: .blue, videoDelegate: videoDelegate)
            }
            if showRaw {
                RawDataChartView( parent:self )
            }
            Spacer()
        }.onAppear(perform: {self.videoDelegate.initialize( parent:self )})
        
    }
}

struct ProgressBar: View {
    @Binding var value:CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .opacity(0.1)
                Rectangle()
                    .frame(minWidth: 0, idealWidth:self.getProgressBarWidth(geometry: geometry),
                                maxWidth: self.getProgressBarWidth(geometry: geometry))
                    .opacity(0.5)
                    .background(Color.blue)
                    .animation(.default)
            }
         }
    }
    
    func getProgressBarWidth(geometry:GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        return frame.size.width * value
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum CameraState {
    case stopped
    case running
    case paused
}

struct ButtonImage: View {
    var imageAsset:String
    var body: some View {
        Image(imageAsset)
            .resizable()
            .scaledToFit()
            .frame(width: 32.0,height:32.0)
    }
}
