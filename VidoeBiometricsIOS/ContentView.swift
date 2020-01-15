//
//  ContentView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/7/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var showVideo = true
    @State var showRaw = false
    @State var showFiltered = false
    @State var showFFT = false
    
    @State var startStopVideoButton = "Start"
    @State var heartRateLabel = "Heart Rate: N/A"
    @State var progressBarValue:CGFloat = 0
    @State var frameNumberLabel = "Frame: "

    var lineChartsRaw = LineCharts()
    var lineChartsFiltered = LineCharts()
    var barChartsFFT = BarCharts()
    let videoProcessor = VideoProcessor()
        
    var body: some View {
        VStack{
            HStack( spacing: 20){
                Button(action: {
                    self.showVideo = true
                    self.showRaw = false
                    self.showFiltered = false
                    self.showFFT = false
                }) {
                    ButtonImage(imageAsset:"Video-camera")
                }
                .padding(.leading, 10)
                .buttonStyle(ToolbarButtonStyle( state:self.showVideo))
                
                Spacer()
                Button(action: {
                    self.showVideo = false
                    self.showRaw = true
                    self.showFiltered = false
                    self.showFFT = false
                }) {
                    ButtonImage(imageAsset:"Raw-waveform")
                }
                .buttonStyle(ToolbarButtonStyle( state:self.showRaw))
                
                Spacer()
                Button(action: {
                    self.showVideo = false
                    self.showRaw = false
                    self.showFiltered = true
                    self.showFFT = false
                }) {
                    ButtonImage(imageAsset:"Filtered-waveform")
                }
                .buttonStyle(ToolbarButtonStyle( state:self.showFiltered))
                
                Spacer()
                Button(action: {
                    self.showVideo = false
                    self.showRaw = false
                    self.showFiltered = false
                    self.showFFT = true
                }) {
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
            Button(action: {
                self.videoProcessor.startStopCamera()
            }) {
                Text(startStopVideoButton)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(10)
                .font(Font.system(size: 36))
            }
            .background(Color.blue)
            .foregroundColor(.white)

            if showVideo {
                VideoView(bgColor: .blue, videoDelegate: videoProcessor)
            }
            if showRaw {
                RawDataChartView( parent:self )
            }
            if showFiltered{
                FilteredDataChartView( parent:self )
            }
            if showFFT{
                FftDataChartView(parent:self)
            }
            Spacer()
        }.onAppear(perform: {self.videoProcessor.initialize( parent:self )})
        
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


struct ButtonImage: View {
    var imageAsset:String
    var body: some View {
        Image(imageAsset)
            .resizable()
            .scaledToFit()
            .frame(width: 32.0,height:32.0)
    }
}

struct ToolbarButtonStyle: ButtonStyle {
    var state:Bool
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(state ? 1.5 : 1.0)
    }
}
