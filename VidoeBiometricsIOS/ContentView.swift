//
//  ContentView.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/7/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI

enum MainView {
    case video
    case rawData
    case filteredData
    case FFTData
    case settings
}


struct ContentView: View {
    
    @State var mainView = MainView.video
        
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
                    self.mainView = MainView.video
                }) {
                    ButtonImage(imageAsset:"Video-camera")
                }
                .padding(.leading, 10)
                .buttonStyle(ToolbarButtonStyle( state:mainView == MainView.video))
                
                Spacer()
                Button(action: {
                    self.mainView = MainView.rawData
                }) {
                    ButtonImage(imageAsset:"Raw-waveform")
                }
                .buttonStyle(ToolbarButtonStyle( state:mainView == MainView.rawData))
                
                Spacer()
                Button(action: {
                    self.mainView = MainView.filteredData
                }) {
                    ButtonImage(imageAsset:"Filtered-waveform")
                }
                .buttonStyle(ToolbarButtonStyle( state:mainView == MainView.filteredData))
                
                Spacer()
                Button(action: {
                    self.mainView = MainView.FFTData
                }) {
                     ButtonImage(imageAsset:"FFT-waveform")
                }
                .buttonStyle(ToolbarButtonStyle( state:mainView == MainView.FFTData))
                
                Spacer()
                Button(action: {
                    self.mainView = MainView.settings
                }) {
                     ButtonImage(imageAsset:"settings")
                }
                .padding(.trailing, 10)
                .buttonStyle(ToolbarButtonStyle( state:mainView == MainView.settings))

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

            if mainView == MainView.video {
                VideoView(bgColor: .blue, videoDelegate: videoProcessor)
            }
            if  mainView == MainView.rawData {
                RawDataChartView( parent:self )
            }
            if  mainView == MainView.filteredData {
                FilteredDataChartView( parent:self )
            }
            if  mainView == MainView.FFTData {
                FftDataChartView(parent:self)
            }
            if  mainView == MainView.settings {
                SettingsView(parent:self)
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
