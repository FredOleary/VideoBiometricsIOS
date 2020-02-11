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
    
    // Max RGB delta (empirical!!)
    let maxDelta = 100.0
    
    let minNoOfPeaks = 3
    
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

    var maxRedPeaks: [(Double, Double)]?
    var maxGreenPeaks: [(Double, Double)]?
    var maxBluePeaks: [(Double, Double)]?

    var ICAmaxRedPeaks: [(Double, Double)]?
    var ICAmaxGreenPeaks: [(Double, Double)]?
    var ICAmaxBluePeaks: [(Double, Double)]?

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

    // HeartRate data from peak detect (value, standard deviation)
    var heartRatePeakRed:(Double, Double)?
    var heartRatePeakGreen:(Double, Double)?
    var heartRatePeakBlue:(Double, Double)?
    
    // ICA HeartRate data from peak detect (value, standard deviation)
    var ICAheartRatePeakRed:(Double, Double)?
    var ICAheartRatePeakGreen:(Double, Double)?
    var ICAheartRatePeakBlue:(Double, Double)?


    // 'Calculated' HR
    var heartRateFrequency: Double?
    var heartRateFrequencyICA: Double?
    
    let testAccelerate = TestAccelerate()
    let fft = FFT()

    // For testing predefined/mock data!!! Must be 0 for real heart rate
    let useConstRGBData = 0;
    
    var temporalFilter:TemporalFilter?
    
    init( _ openCVWrapper:OpenCVWrapper ){
        self.openCVWrapper = openCVWrapper
        temporalFilter = TemporalFilter()
    }
    
    func calculateHeartRate( _ actualFPS:Double){
        var ICARedMax:Double = 0
        var ICAGreenMax:Double = 0
        var ICABlueMax:Double = 0
        var frameRate = actualFPS

        timeSeries = testAccelerate.makeTimeSeries()
        if( useConstRGBData == 1){
            // NOTE: This requires 300 samples at 30FPS....
            let rgbSampleData = RGBSampleData()
            frameRate = Double(Settings.getFrameRate())
            (rawRedPixels, rawGreenPixels, rawBluePixels) = rgbSampleData.getRGBData()
        }else if( useConstRGBData == 2){
            let fps = Settings.getFrameRate()
            let count = Settings.getFramesPerHeartRateSample()
            rawRedPixels = TestAccelerate.makeSineWave(0.8, fps: fps, noOfSamples: count)
            rawGreenPixels = TestAccelerate.makeSineWave(1.0166666, fps: fps, noOfSamples: count)
            rawBluePixels = TestAccelerate.makeSineWave( 1.2, fps: fps, noOfSamples: count)
            frameRate = Double(fps)
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
            timeSeries = calcTimeSeries(count: rawRedPixels!.count, fps: frameRate)
        }
//        deltaRawRed = deltaRawPixels( rawRedPixels! )
//        deltaRawGreen = deltaRawPixels( rawGreenPixels! )
//        deltaRawBlue = deltaRawPixels( rawBluePixels! )
        
        normalizedRedAmplitude = normalizePixels( rawRedPixels! )
        normalizedGreenAmplitude = normalizePixels( rawGreenPixels! )
        normalizedBlueAmplitude = normalizePixels( rawBluePixels! )

//        normalizedRedAmplitude = normalizePixels( deltaRawRed! )
//        normalizedGreenAmplitude = normalizePixels( deltaRawGreen! )
//        normalizedBlueAmplitude = normalizePixels( deltaRawBlue! )


        let filterStart = Settings.getFilterStart()
        let filterEnd = Settings.getFilterEnd()
        filteredRedAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: normalizedRedAmplitude!, sampleRate:frameRate, filterLoRate: filterStart, filterHiRate: filterEnd))!)
        filteredGreenAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: normalizedGreenAmplitude!, sampleRate:frameRate, filterLoRate: filterStart, filterHiRate: filterEnd))!)
        filteredBlueAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: normalizedBlueAmplitude!, sampleRate:frameRate, filterLoRate: filterStart, filterHiRate: filterEnd))!)
        
        assert(filteredRedAmplitude!.count == timeSeries!.count)
        assert(filteredGreenAmplitude!.count == timeSeries!.count)
        assert(filteredBlueAmplitude!.count == timeSeries!.count)
        
//        // TODO Make lookahead/delta be dynamic...
//        let delta = 0.1
//        (maxRedPeaks, _) = PeakDetect.peakDetect(yAxis: filteredRedAmplitude!, xAxis: timeSeries!, lookAhead: 10, delta: delta)
//        (maxGreenPeaks, _) = PeakDetect.peakDetect(yAxis: filteredGreenAmplitude!, xAxis: timeSeries!, lookAhead: 10, delta: delta)
//        (maxBluePeaks, _) = PeakDetect.peakDetect(yAxis: filteredBlueAmplitude!, xAxis: timeSeries!, lookAhead: 10, delta: delta)
//
//        heartRatePeakRed = calculateHeartRateFromPeaks(maxRedPeaks!, filterStart, filterEnd )
//        heartRatePeakGreen = calculateHeartRateFromPeaks(maxGreenPeaks!, filterStart, filterEnd )
//        heartRatePeakBlue = calculateHeartRateFromPeaks(maxBluePeaks!, filterStart, filterEnd )
////        heartRateFrequency = hrGreen

        (FFTRedAmplitude, FFTRedFrequency, heartRateRedFrequency, _) = fft.calculate( filteredRedAmplitude!, fps: frameRate)
        (FFTGreenAmplitude, FFTGreenFrequency, heartRateGreenFrequency, _) = fft.calculate( filteredGreenAmplitude!, fps: frameRate)
        (FFTBlueAmplitude, FFTBlueFrequency, heartRateBlueFrequency, _) = fft.calculate( filteredBlueAmplitude!, fps: frameRate)
        heartRateFrequency = heartRateGreenFrequency // May need fixup
        
        if( calculateICA()){
            ICARedAmplitude = normalizePixels( ICARedAmplitude! )
            ICAGreenAmplitude = normalizePixels( ICAGreenAmplitude! )
            ICABlueAmplitude = normalizePixels( ICABlueAmplitude! )
            ICARedAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: ICARedAmplitude!, sampleRate:frameRate, filterLoRate: filterStart, filterHiRate: filterEnd))!)
            ICAGreenAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: ICAGreenAmplitude!, sampleRate:frameRate, filterLoRate: filterStart, filterHiRate: filterEnd))!)
            ICABlueAmplitude = normalizePixels((temporalFilter?.bandpassFilter(dataIn: ICABlueAmplitude!, sampleRate:frameRate, filterLoRate: filterStart, filterHiRate: filterEnd))!)

            (ICAFFTRedAmplitude, ICAFFTRedFrequency, ICAheartRateRedFrequency, ICARedMax) = fft.calculate( ICARedAmplitude!, fps: frameRate)
            (ICAFFTGreenAmplitude, ICAFFTGreenFrequency, ICAheartRateGreenFrequency, ICAGreenMax) = fft.calculate( ICAGreenAmplitude!, fps: frameRate)
            (ICAFFTBlueAmplitude, ICAFFTBlueFrequency, ICAheartRateBlueFrequency, ICABlueMax) = fft.calculate( ICABlueAmplitude!, fps: frameRate)
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
//            let ICADelta = 0.1
//            (ICAmaxRedPeaks, _) = PeakDetect.peakDetect(yAxis: ICARedAmplitude!, xAxis: timeSeries!, lookAhead: 10, delta: ICADelta)
//            (ICAmaxGreenPeaks, _) = PeakDetect.peakDetect(yAxis: ICAGreenAmplitude!, xAxis: timeSeries!, lookAhead: 10, delta: ICADelta)
//            (ICAmaxBluePeaks, _) = PeakDetect.peakDetect(yAxis: ICABlueAmplitude!, xAxis: timeSeries!, lookAhead: 10, delta: ICADelta)
//
//            ICAheartRatePeakRed = calculateHeartRateFromPeaks(ICAmaxRedPeaks!, filterStart, filterEnd )
//            ICAheartRatePeakGreen = calculateHeartRateFromPeaks(ICAmaxGreenPeaks!, filterStart, filterEnd )
//            ICAheartRatePeakBlue = calculateHeartRateFromPeaks(ICAmaxBluePeaks!, filterStart, filterEnd )


        }
        // Calculate heart rates from peak data
        var peakCalculation = PeakCalculation( waveForm:filteredRedAmplitude, timeSeries:timeSeries, filterStart:filterStart, filterEnd:filterEnd)
        heartRatePeakRed = peakCalculation.calculateHRFromPeaks()
        peakCalculation = PeakCalculation( waveForm:filteredGreenAmplitude, timeSeries:timeSeries, filterStart:filterStart, filterEnd:filterEnd)
        heartRatePeakGreen = peakCalculation.calculateHRFromPeaks()
        peakCalculation = PeakCalculation( waveForm:filteredBlueAmplitude, timeSeries:timeSeries, filterStart:filterStart, filterEnd:filterEnd)
        heartRatePeakBlue = peakCalculation.calculateHRFromPeaks()

        peakCalculation = PeakCalculation( waveForm:ICARedAmplitude, timeSeries:timeSeries, filterStart:filterStart, filterEnd:filterEnd)
        ICAheartRatePeakRed = peakCalculation.calculateHRFromPeaks()
        peakCalculation = PeakCalculation( waveForm:ICAGreenAmplitude, timeSeries:timeSeries, filterStart:filterStart, filterEnd:filterEnd)
        ICAheartRatePeakGreen = peakCalculation.calculateHRFromPeaks()
        peakCalculation = PeakCalculation( waveForm:ICABlueAmplitude, timeSeries:timeSeries, filterStart:filterStart, filterEnd:filterEnd)
        ICAheartRatePeakBlue = peakCalculation.calculateHRFromPeaks()

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
    func calculateHeartRateFromPeaks( _ peaks:[(Double, Double)], _ filterLow:Double, _ filterHigh:Double ) -> (Double, Double){
        var heartRateData = (0.0,0.0)
        var count = 0
        var heartRate = 0.0
        var peakList = [Double]()
        if( peaks.count > 1 ){
            for n in 1...peaks.count-1 {
                let ( _ , freq1 ) = peaks[n-1]
                let ( _ , freq2 ) = peaks[n]
                let freq = 1/(freq2 - freq1)
                if( freq >= filterLow && freq <= filterHigh){
                    peakList.append(freq)
                    heartRate += freq
                    count += 1
                }
            }
            if count > minNoOfPeaks {
                heartRate /= Double(count) // Average heart rate
                var variance = 0.0
                for n in 0...peakList.count-1{
                    variance += pow((heartRate - peakList[n]), 2)
                }
                let stdDeviation = sqrt(variance/Double((count-1)))
                heartRateData = (heartRate, stdDeviation)
            }
        }
        return heartRateData
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
//        if( count >= 1024 ) { return 1024 }
//        if( count >= 512 ) { return 512 }
//        if( count >= 256 ) { return 256 }
//        if( count >= 128 ) { return 128 }
//        if( count >= 64 ) { return 64 }
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
