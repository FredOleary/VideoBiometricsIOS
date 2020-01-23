//
//  ViewModel.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/15/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import SwiftUI
import Combine

class UserSettings: ObservableObject {

    let objectWillChange = ObservableObjectPublisher()
    var pauseBetweenSamples = Settings.getPauseBetweenSamples() {
        didSet {
//            print("pauseBetweenSamples \(pauseBetweenSamples)")
            Settings.setPauseBetweenSamples(pauseBetweenSamples)
            objectWillChange.send()
        }
    }
    var filterStart = String( format: "%.2f", Settings.getFilterStart()){
        didSet {
            guard let value = Double(filterStart) else {
                return
            }
            Settings.setFilterStart(value)
            objectWillChange.send()
        }
    }
    var filterEnd = String( format: "%.2f", Settings.getFilterEnd()){
        didSet {
            guard let value = Double(filterEnd) else {
                return
            }
            Settings.setFilterEnd(value)
            objectWillChange.send()
        }
    }
    var frameRate = Settings.getFrameRate(){
        didSet{
            Settings.setFrameRate(frameRate)
            objectWillChange.send()
        }
    }
    var framesPerHeartRateSample = String( format: "%d", Settings.getFramesPerHeartRateSample()){
        didSet {
            guard let value = Int(framesPerHeartRateSample) else {
                return
            }
            Settings.setFramesPerHeartRateSample(value)
            objectWillChange.send()
        }
    }

}
