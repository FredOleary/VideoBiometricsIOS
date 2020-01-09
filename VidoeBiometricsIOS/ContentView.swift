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
    func frameReady(_ frame: UIImage) {
        print("VideoDelegate:frameReady")
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
                fooView(bgColor: .red)
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

struct DetailView: View {
    var body: some View {
        Rectangle()
            .foregroundColor(.blue)
    }
}


struct VideoView: View {
    var bgColor: Color
    var openCVWrapper:OpenCVWrapper
    var videoDelegate:VideoDelegate
    
    @State var videoFrame: UIImage = UIImage(imageLiteralResourceName: "Heart-icon")
    
    init( bgColor:Color, cvWrapper:OpenCVWrapper, videoDelegate:VideoDelegate ){
        print("VideoView-init()")
        self.bgColor = bgColor
        self.openCVWrapper = cvWrapper
        self.videoDelegate = videoDelegate
        
        print("\(openCVWrapper.openCVVersionString())")
    }
    var body: some View {
        VStack{
            Button(action: {
                self.openCVWrapper.initializeCamera( 300);
                self.openCVWrapper.startCamera();
            }) {
                Text("Start Video")
            }
            Image(uiImage:videoFrame ).onAppear(perform: fixupVideoFrame)
        }
        
    }
    private func fixupVideoFrame(){
        videoDelegate.videoView = self
    }

}

struct fooView: View {
    var bgColor: Color
    var body: some View {
        Rectangle()
            .foregroundColor(bgColor)
    }
}
