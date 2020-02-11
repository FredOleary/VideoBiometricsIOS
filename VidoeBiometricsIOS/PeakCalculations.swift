//
//  PeakCalculations.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 2/3/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import Foundation

struct peakSummary {
    let count:Int
    let mean:Double
    let stdDeviation:Double
    let delta:Double
    let valid:Bool
    
}
class PeakCalculation {
    // Constants
    let peakDelta = 0.05    // Adjustment for peak detector
    let maxPeak = 0.5
    let minPeaks = 5        // Min no of peaks to constitute a valid sample. With 10 seconds of data an 1 beat per second 10 peaks would be measure
    let lookAhead = 10      // To avoid jitter... may need refining

    let waveForm:[Double]?
    let timeSeries:[Double]?
    let filterStart:Double
    let filterEnd:Double

    var maxPeaks: [(Double, Double)]?
    
    init( waveForm:[Double]?, timeSeries:[Double]?, filterStart:Double, filterEnd:Double){
        self.waveForm = waveForm
        self.timeSeries = timeSeries
        self.filterStart = filterStart
        self.filterEnd = filterEnd
    }
    func calculateHRFromPeaks() ->(Double, Double)? {
        var peaks:[peakSummary] = [peakSummary]()
        var heartRateMeanAndStdDeviation:(Double, Double)?
        var nextPeak = peakDelta
        if let waveData = waveForm{
            if let timeData = timeSeries{
                repeat {
                    (maxPeaks, _) = PeakDetect.peakDetect(yAxis: waveData, xAxis: timeData, lookAhead: lookAhead, delta: nextPeak)
                    if let peakInfo = maxPeaks {
                        let peakSummary = calculateHeartRateFromPeaks( peakInfo, filterStart, filterEnd, nextPeak )
                        peaks.append(peakSummary)
                    }

                    nextPeak += peakDelta
                }while nextPeak < maxPeak
                
                let count = Double((peaks.filter{$0.valid}).count)  // Number of valid
                if count > 0{
                    let averageHeartRate = (peaks.reduce(0.0) { $0 + $1.mean})/count
                    let averageStdDeviation = (peaks.reduce(0.0) { $0 + $1.stdDeviation})/count
                    heartRateMeanAndStdDeviation = (averageHeartRate, averageStdDeviation)
                }
            }
        }
        return heartRateMeanAndStdDeviation
    }
    private func calculateHeartRateFromPeaks( _ peakInfo:[(Double, Double)], _ filterStart:Double, _ filterEnd:Double, _ delta:Double) -> peakSummary {
        var heartRateMean = 0.0
        var heartRateCount = 0
        var heartRateStdDeviation = 0.0
        var valid = false
        
        var heartRate = 0.0
        var peakList = [Double]()
        if( peakInfo.count > 1 ){
            for n in 1...peakInfo.count-1 {
                let ( _ , freq1 ) = peakInfo[n-1]
                let ( _ , freq2 ) = peakInfo[n]
                let freq = 1/(freq2 - freq1)
                if( freq >= filterStart && freq <= filterEnd){
                    peakList.append(freq)
                    heartRate += freq
                    heartRateCount += 1
                }
            }
            if heartRateCount >= minPeaks {
                heartRateMean = heartRate / Double(heartRateCount) // Average heart rate
                var variance = 0.0
                for n in 0...peakList.count-1{
                    variance += pow((heartRateMean - peakList[n]), 2)
                }
                heartRateStdDeviation = sqrt(variance/Double((heartRateCount-1)))
                valid = true
            }
        }
        return peakSummary(count:heartRateCount, mean:heartRateMean, stdDeviation: heartRateStdDeviation, delta:delta, valid:valid)

    }
}
