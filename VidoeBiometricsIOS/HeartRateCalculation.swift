//
//  HeartRateCalculation.swift
//  mac_min2
//
//  Created by Fred OLeary on 12/11/19.
//  Copyright © 2019 Fred OLeary. All rights reserved.
//

import Foundation

class HeartRateCalculation{
    var openCVWrapper:OpenCVWrapper
    
    // Time Series
    var timeSeries: [Double]?
    
    // Max RDB delta (empirical!!)
    let maxDelta = 100.0
    
    // Raw data as captured by the image processor
    var rawRedPixels: [Double]?
    var rawGreenPixels: [Double]?
    var rawBluePixels: [Double]?
    
    // Normalized data
    var normalizedRedAmplitude: [Double]?
    var normalizedGreenAmplitude: [Double]?
    var normalizedBlueAmplitude: [Double]?

    var deltaRawRed: [Double]?
    var deltaRawGreen: [Double]?
    var deltaRawBlue: [Double]?

    // Filtered data
    var filteredRedAmplitude: [Double]?
    var filteredGreenAmplitude: [Double]?
    var filteredBlueAmplitude: [Double]?

    // FFT data
    var FFTRedAmplitude: [Double]?
    var FFTRedFrequency: [Double]?

    var FFTGreenAmplitude: [Double]?
    var FFTGreenFrequency: [Double]?

    var FFTBlueAmplitude: [Double]?
    var FFTBlueFrequency: [Double]?

    // ICA processed data
    var ICARedAmplitude: [Double]?
    var ICAGreenAmplitude: [Double]?
    var ICABlueAmplitude: [Double]?

    var ICAFFTRedAmplitude: [Double]?
    var ICAFFTRedFrequency: [Double]?

    var ICAFFTGreenAmplitude: [Double]?
    var ICAFFTGreenFrequency: [Double]?

    var ICAFFTBlueAmplitude: [Double]?
    var ICAFFTBlueFrequency: [Double]?


    // Summary of heart rate calulations
    var heartRateRedFrequency: Double?
    var heartRateGreenFrequency: Double?
    var heartRateBlueFrequency: Double?
    
    // Summary of heart rate calulations
    var ICAheartRateRedFrequency: Double?
    var ICAheartRateGreenFrequency: Double?
    var ICAheartRateBlueFrequency: Double?

    // 'Calculated' HR
    var heartRateFrequency: Double?
    var heartRateFrequencyICA: Double?
    
    let testAccelerate = TestAccelerate()
    let fft = FFT()

    let useConstRGBData = false;
    
    var temporalFilter:TemporalFilter?
    
    init( _ openCVWrapper:OpenCVWrapper ){
        self.openCVWrapper = openCVWrapper
        temporalFilter = TemporalFilter()
    }
    
    func calculateHeartRate( _ actualFPS:Double){
        var ICARedMax:Double = 0
        var ICAGreenMax:Double = 0
        var ICABlueMax:Double = 0

        timeSeries = testAccelerate.makeTimeSeries()
        if( useConstRGBData ){
            let rgbSampleData = RGBSampleData()
            (rawRedPixels, rawGreenPixels, rawBluePixels) = rgbSampleData.getRGBData()
        }else{
            if let rawRed = openCVWrapper.getRedPixels() as NSArray as? [Double]{
                if let rawGreen = openCVWrapper.getGreenPixels() as NSArray as? [Double]{
                    if let rawBlue = openCVWrapper.getBluePixels() as NSArray as? [Double]{
                        rawRedPixels = rawRed
                        rawGreenPixels = rawGreen
                        rawBluePixels = rawBlue
                    }
                }
            }
            timeSeries = calcTimeSeries(count: rawRedPixels!.count, fps: actualFPS)
        }
        deltaRawRed = deltaRawPixels( rawRedPixels! )
        deltaRawGreen = deltaRawPixels( rawGreenPixels! )
        deltaRawBlue = deltaRawPixels( rawBluePixels! )
        
        normalizedRedAmplitude = normalizePixels( rawRedPixels! )
        normalizedGreenAmplitude = normalizePixels( rawGreenPixels! )
        normalizedBlueAmplitude = normalizePixels( rawBluePixels! )

//        normalizedRedAmplitude = normalizePixels( deltaRawRed! )
//        normalizedGreenAmplitude = normalizePixels( deltaRawGreen! )
//        normalizedBlueAmplitude = normalizePixels( deltaRawBlue! )


        let filterStart = Settings.getFilterStart()
        let filterEnd = Settings.getFilterEnd()
        filteredRedAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: normalizedRedAmplitude!, sampleRate:actualFPS, filterLoRate: filterStart, filterHiRate: filterEnd))!)
        filteredGreenAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: normalizedGreenAmplitude!, sampleRate:actualFPS, filterLoRate: filterStart, filterHiRate: filterEnd))!)
        filteredBlueAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: normalizedBlueAmplitude!, sampleRate:actualFPS, filterLoRate: filterStart, filterHiRate: filterEnd))!)
        
        (FFTRedAmplitude, FFTRedFrequency, heartRateRedFrequency, _) = fft.calculate( filteredRedAmplitude!, fps: actualFPS)
        (FFTGreenAmplitude, FFTGreenFrequency, heartRateGreenFrequency, _) = fft.calculate( filteredGreenAmplitude!, fps: actualFPS)
        (FFTBlueAmplitude, FFTBlueFrequency, heartRateBlueFrequency, _) = fft.calculate( filteredBlueAmplitude!, fps: actualFPS)
        heartRateFrequency = heartRateGreenFrequency // May need fixup
        
        if( calculateICA()){
            ICARedAmplitude = normalizePixels( ICARedAmplitude! )
            ICAGreenAmplitude = normalizePixels( ICAGreenAmplitude! )
            ICABlueAmplitude = normalizePixels( ICABlueAmplitude! )
            ICARedAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: ICARedAmplitude!, sampleRate:actualFPS, filterLoRate: filterStart, filterHiRate: filterEnd))!)
            ICAGreenAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: ICAGreenAmplitude!, sampleRate:actualFPS, filterLoRate: filterStart, filterHiRate: filterEnd))!)
            ICABlueAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: ICABlueAmplitude!, sampleRate:actualFPS, filterLoRate: filterStart, filterHiRate: filterEnd))!)

            (ICAFFTRedAmplitude, ICAFFTRedFrequency, ICAheartRateRedFrequency, ICARedMax) = fft.calculate( ICARedAmplitude!, fps: actualFPS)
            (ICAFFTGreenAmplitude, ICAFFTGreenFrequency, ICAheartRateGreenFrequency, ICAGreenMax) = fft.calculate( ICAGreenAmplitude!, fps: actualFPS)
            (ICAFFTBlueAmplitude, ICAFFTBlueFrequency, ICAheartRateBlueFrequency, ICABlueMax) = fft.calculate( ICABlueAmplitude!, fps: actualFPS)
            // Take the maximim of the max RGB amplitudes
            heartRateFrequencyICA = ICAheartRateRedFrequency
            if( ICAGreenMax > ICARedMax){
                heartRateFrequencyICA = ICAheartRateGreenFrequency
                if( ICABlueMax > ICAGreenMax){
                    heartRateFrequencyICA = ICAheartRateBlueFrequency
                }
            }else if( ICABlueMax > ICARedMax){
                heartRateFrequencyICA = ICAheartRateBlueFrequency
            }

        }
    }
    func calculateICA() -> Bool {
        if( normalizedRedAmplitude != nil ){
            
            assert(normalizedRedAmplitude!.count == normalizedGreenAmplitude!.count)
            assert(normalizedRedAmplitude!.count == normalizedBlueAmplitude!.count)
            var gridData = [Double]()
            var inputMatrix : Matrix<Double> = Matrix(rows: normalizedRedAmplitude!.count, columns: 3, repeatedValue: 0.0)
            for i in 0..<normalizedRedAmplitude!.count{
                gridData.append(normalizedRedAmplitude![i])
                gridData.append(normalizedGreenAmplitude![i])
                gridData.append(normalizedBlueAmplitude![i])
            }
            inputMatrix.grid = gridData
            
            
            let result = fastICA(_X: inputMatrix, compc: 3)
            if( result.S.endIndex == 3 * normalizedRedAmplitude!.count){
                ICARedAmplitude = [Double](repeating: 0, count: result.S.rows)
                ICAGreenAmplitude = [Double](repeating: 0, count: result.S.rows)
                ICABlueAmplitude = [Double](repeating: 0, count: result.S.rows)

                for i in 0..<result.S.rows{
                    ICARedAmplitude![i] = result.S.grid[i*3]
                    ICAGreenAmplitude![i] = result.S.grid[(i*3)+1]
                    ICABlueAmplitude![i] = result.S.grid[(i*3)+2]
                }
                return true
            }
            
        }
        return false
    }
    func deltaRawPixels( _ pixels:[Double]) ->[Double] {
        if(pixels.count > 0){
            var delta:[Double] = [Double](repeating: 0.0, count: pixels.count)
            for i in 1..<pixels.count {
                var deltaVal = pixels[i] - pixels[i-1]
                if( abs(deltaVal) > maxDelta ){
                    deltaVal = deltaVal >= 0 ? maxDelta : -maxDelta
                }
                delta[i] = deltaVal
            }
            return delta
        }
        return pixels
    }
    
//    func normalizePixels( _ pixels:[Double] ) ->[Double]{
////        var xPixels = pixels
////        if(pixels.count > 256){
////            xPixels = pixels.suffix(256)
////
////        }
//        if(pixels.count > 0){
//            let min = pixels.min()!
//            let range = pixels.max()! - min
//            return pixels.map {($0-min)/range}
//        }else{
//            return pixels
//        }
//    }
//
    func normalizePixels( _ pixels:[Double] ) ->[Double]{
        var xPixels = pixels

        if(pixels.count > 0){
            xPixels = pixels.suffix( getPowerOf2Count(count: pixels.count))
            let min = xPixels.min()!
            let range = xPixels.max()! - min
            return xPixels.map {($0-min)/range}
        }else{
            return pixels
        }

    }
    func getPowerOf2Count( count:Int) -> Int {
        if( count >= 1024 ) { return 1024 }
        if( count >= 512 ) { return 512 }
        if( count >= 256 ) { return 256 }
        if( count >= 128 ) { return 128 }
        if( count >= 64 ) { return 64 }
        return count
    }
    
    func calcTimeSeries( count:Int, fps:Double) -> [Double]{
        let seconds = Double(count)/fps
        let timeSeries = (0..<count).map{
            Double($0) * seconds/Double(count)
        }
        return timeSeries

    }

}
