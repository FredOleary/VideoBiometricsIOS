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
    var videoProcessor:VideoProcessor
    
    @State var videoFrame: UIImage = UIImage(imageLiteralResourceName: "Heart-icon")
    
    init( bgColor:Color, videoDelegate:VideoProcessor ){
        print("VideoView-init()")
        self.bgColor = bgColor
        self.videoProcessor = videoDelegate
    }
    var body: some View {
        VStack{
           Image(uiImage:videoFrame )
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .onAppear(perform: fixupVideoFrame)
        }
        
    }
    private func fixupVideoFrame(){
        videoProcessor.videoView = self
    }
}
