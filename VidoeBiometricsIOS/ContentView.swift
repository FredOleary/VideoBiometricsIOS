//
//  ContentView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/7/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI

class VideoDelegate: NSObject, OpenCVWrapperDelegate{
    var videoView:VideoView? = nil
    var parent:ContentView?
    var cameraRunning = CameraState.stopped;

    func frameAvailable(_ frame: UIImage) {
//        print("VideoDelegate:frameAvailable")
        videoView?.videoFrame = frame
    }
    
    func framesReady(_ videoProcessingPaused: Bool) {
        print("ViewController: framesReady videoProcessingPaused: ", videoProcessingPaused)
        if( videoProcessingPaused){
//            let pauseBetweenSamples = Settings.getPauseBetweenSamples()
            let pauseBetweenSamples = true
            if( pauseBetweenSamples ){
                DispatchQueue.main.async {
                        self.cameraRunning = CameraState.paused
                        self.parent?.startStopVideoButton = "Resume"
                }
            }else{
                self.parent!.openCVWrapper.resumeCamera();
            }
            self.parent!.heartRateCalculation.calculateHeartRate()
            var heartRateStr:String = "Heart Rate: N/A"
            let hrFrequency = calculateHeartRate()
            if( hrFrequency > 0){
                let hrFrequencyICA = calculateHeartRateFromICA()
                heartRateStr = NSString(format: "Heart Rate %.1f/%.1f", hrFrequency, hrFrequencyICA) as String
            }
            DispatchQueue.main.async {
                    self.parent?.heartRateLabel = heartRateStr
            }


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
        self.parent = parent
        parent.openCVWrapper.initializeCamera(300)
    }
    func startStopCamera(){
        if( cameraRunning == CameraState.stopped ){
            cameraRunning = CameraState.running;
            self.parent!.openCVWrapper.startCamera();
            self.parent!.startStopVideoButton = "Stop"
        }else if( cameraRunning == CameraState.running ){
            cameraRunning = CameraState.stopped;
            self.parent!.openCVWrapper.stopCamera();
            self.parent!.startStopVideoButton = "Start"
        }else if( cameraRunning == CameraState.paused ){
            cameraRunning = CameraState.running;
            self.parent!.openCVWrapper.resumeCamera();
            self.parent!.startStopVideoButton = "Stop"
        }

    }
    func calculateHeartRate() -> Double{
        return parent!.heartRateCalculation.heartRateFrequency! * 60.0
    }
    func calculateHeartRateFromICA() -> Double{
        return parent!.heartRateCalculation.heartRateFrequencyICA! * 60.0
    }

}

struct ContentView: View {
    let openCVWrapper:OpenCVWrapper = OpenCVWrapper()
    var heartRateCalculation:HeartRateCalculation
    
    @State var showVideo = true
    @State var showRaw = false
    @State var startStopVideoButton = "Start"
    @State var heartRateLabel = "Heart Rate: N/A"

    var lineChartsRaw = LineCharts()
    let videoDelegate = VideoDelegate()
    
    init(){
        openCVWrapper.delegate = videoDelegate
        heartRateCalculation = HeartRateCalculation( openCVWrapper )
    }
    var body: some View {
        VStack{
            HStack( spacing: 20){
                Button(action: {
                    self.showVideo = true
                    self.showRaw = false
                }) {
                    Text("Video")
                
                }
                Spacer()
                Button(action: {
                    self.showVideo = false
                    self.showRaw = true

                }) {
                    Text("Raw")
                }
                Spacer()
                Button(action: {}) {
                    Text("Filtered")
                }
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                    Text("FFT")
                }
            }
            HStack{
                Text("FrameX:")
                Spacer()
                Text(heartRateLabel)
            }
            Button(action: {
                self.videoDelegate.startStopCamera()
            }) {
                Text(startStopVideoButton)
            }

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
