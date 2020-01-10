//
//  VideoView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/10/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI

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
