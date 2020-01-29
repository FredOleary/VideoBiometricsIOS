//
//  PeakDetect.swift
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 1/27/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

import Foundation
class PeakDetect{
    static func peakDetect( yAxis:[Double], xAxis:[Double], lookAhead:Int, delta:Double ) -> (([(Double,Double)], [(Double,Double)])){
        var maxList = [(Double, Double)]()    // Array of maximums - Value and Index
        var minList = [(Double, Double)]()    // Array of minimums
        var discard = [Bool]()      // Always disard the first min/max
        
        // Min/max candidates
        var minCandidate = Double.infinity
        var maxCandidate = -Double.infinity
        var maxIndex = 0
        var minIndex = 0
        for (index, value) in yAxis.enumerated() {
            if value > maxCandidate{
                maxCandidate = value
                maxIndex = index
            }
            if value < minCandidate{
                minCandidate = value
                minIndex = index
            }

            // look for maximum
            if value < (maxCandidate - delta) && maxCandidate != Double.infinity {
                // Maxima peak candidate found
                // look ahead in signal to ensure that this is a peak and not jitter
                if lookForJitter( yAxis, index, lookAhead, max:true ) < maxCandidate{
                    maxList.append( (maxCandidate, xAxis[maxIndex]) )
//                    maxtab.append((mxpos, mx))
                    discard.append(true)
                    // set algorithm to only find minima now
                    maxCandidate = Double.infinity
                    minCandidate = Double.infinity
                }
            }
            // Look for minimum
            if value > (minCandidate + delta) && minCandidate != -Double.infinity{
                // Minima peak candidate found
                // look ahead in signal to ensure that this is a peak and not jitter
                if lookForJitter( yAxis, index, lookAhead, max:false ) > minCandidate{
                    minList.append((minCandidate, xAxis[minIndex]))
                    discard.append(false)
                    // set algorithm to only find maxima now
                    maxCandidate = -Double.infinity
                    minCandidate = -Double.infinity
                }
            }
        }
        if discard.count > 0{
            let isMax = discard[0]
            if( isMax && maxList.count > 0 ){
                maxList.remove(at:0)
            }else if( !isMax &&  minList.count > 0 ){
                minList.remove(at:0)
            }
        }
        return (maxList, minList)
    }
    static func lookForJitter( _ yAxis:[Double], _ index:Int, _ lookAhead:Int, max:Bool) -> Double{
        var maxMin = (max) ? -Double.infinity : Double.infinity
        for n in 0...lookAhead{
            if n+index < yAxis.count{
                if max {
                    if yAxis[n+index] > maxMin{
                        maxMin = yAxis[n+index]
                    }
                }else{
                    if yAxis[n+index] < maxMin{
                        maxMin = yAxis[n+index]
                    }
                }
            }else{
                return maxMin
            }
        }
        return maxMin
    }
}

