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
//            print("filterStart \(filterStart)")
            Settings.setFilterStart(Double(filterStart)!)
            objectWillChange.send()
        }
    }
    var filterEnd = String( format: "%.2f", Settings.getFilterEnd()){
        didSet {
            Settings.setFilterEnd(Double(filterEnd)!)
            objectWillChange.send()
        }
    }


}
