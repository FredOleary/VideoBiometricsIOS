//
//  Settings.swift
//  mac_min2
//
//  Created by Fred OLeary on 12/17/19.
//  Copyright © 2019 Fred OLeary. All rights reserved.
//

import Foundation
class Settings {
    static var framesPerHeartRateSample = 300
    
    static var filterStart:Double  = 42/60.0
    static var filterEnd:Double  = 150/60
    static var frameRate = 30

    
    struct settingsKeys {
        static let pauseBetweenSamples = "pauseBetweenSamples"
        static let framesPerHeartRateSample = "framesPerHeartRateSample"
        static let filterStart = "filterStart"
        static let filterEnd = "filterEnd"
        static let frameRate = "frameRate"
        
    }

    static func getFramesPerHeartRateSample() -> Int {
        let defaults = UserDefaults.standard
        if self.checkIfKeyExists(settingsKeys.framesPerHeartRateSample){
            return defaults.integer(forKey: settingsKeys.framesPerHeartRateSample)
        }
        return framesPerHeartRateSample
    }
    
    static func setFramesPerHeartRateSample( _ fps:Int) {
        let defaults = UserDefaults.standard
        defaults.set(fps, forKey: settingsKeys.framesPerHeartRateSample)
    }
    static func getFilterStart() -> Double {
        let defaults = UserDefaults.standard
        if self.checkIfKeyExists(settingsKeys.filterStart){
            return defaults.double(forKey: settingsKeys.filterStart)
        }
        return filterStart
    }
    
    static func setFilterStart( _ FStart:Double) {
        let defaults = UserDefaults.standard
        defaults.set(FStart, forKey: settingsKeys.filterStart)
    }
    
    static func getFilterEnd() -> Double {
        let defaults = UserDefaults.standard
        if self.checkIfKeyExists(settingsKeys.filterEnd){
            return defaults.double(forKey: settingsKeys.filterEnd)
        }
        return filterEnd
    }
    
    static func setFilterEnd( _ FEnd:Double) {
        let defaults = UserDefaults.standard
        defaults.set(FEnd, forKey: settingsKeys.filterEnd)
    }

    static func getPauseBetweenSamples() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: settingsKeys.pauseBetweenSamples)
    }
    static func setPauseBetweenSamples( _ pause:Bool) {
        let defaults = UserDefaults.standard
        defaults.set(pause, forKey: settingsKeys.pauseBetweenSamples )
    }

    static func getFrameRate() -> Int {
        let defaults = UserDefaults.standard
        if self.checkIfKeyExists(settingsKeys.frameRate){
            return defaults.integer(forKey: settingsKeys.frameRate)
        }
        return frameRate
    }
    static func setFrameRate( _ frameRate:Int) {
        let defaults = UserDefaults.standard
        defaults.set(frameRate, forKey: settingsKeys.frameRate )
    }

    static private func checkIfKeyExists( _ key:String) -> Bool {
        if (UserDefaults.standard.object(forKey:key) != nil ){
            return true
        }
        return false
    }

}
