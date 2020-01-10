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
    func frameAvailable(_ frame: UIImage) {
//        print("VideoDelegate:frameAvailable")
        videoView?.videoFrame = frame
    }
    
    func framesReady(_ videoProcessingPaused: Bool) {
        print("VideoDelegate- framesReady")
    }
}

struct ContentView: View {
    let openCVWrapper:OpenCVWrapper = OpenCVWrapper();
    @State var showVideo = true
    @State var showRaw = false

    var lineChartsRaw = LineCharts()
    let videoDelegate = VideoDelegate()
    
    init(){
        openCVWrapper.delegate = videoDelegate
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
                Text("Heart Rate")
            }
            if showVideo {
                VideoView(bgColor: .blue, cvWrapper: openCVWrapper, videoDelegate: videoDelegate)
            }
            if showRaw {
                RawDataChartView( parent:self )
            }
            Spacer()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
