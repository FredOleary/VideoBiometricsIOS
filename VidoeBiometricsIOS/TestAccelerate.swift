//
//  test_accelerate.swift
//  mac_min2
//
//  Created by Fred OLeary on 11/26/19.
//  Copyright © 2019 Fred OLeary. All rights reserved.
//

import Foundation
import Accelerate

class TestAccelerate{
    let hrSampleGreen:[Double] = [
    151.27,
    151.21666666666667,
    151.07518518518518,
    151.01037037037037,
    151.01444444444445,
    150.9874074074074,
    150.94703703703703,
    150.9274074074074,
    150.92518518518517,
    150.9148148148148,
    150.85222222222222,
    150.9351851851852,
    151.00444444444443,
    151.0225925925926,
    151.01111111111112,
    151.0388888888889,
    151.00518518518518,
    151.08,
    151.13296296296295,
    151.10222222222222,
    150.9725925925926,
    150.8440740740741,
    150.6688888888889,
    150.58851851851853,
    150.41666666666666,
    150.3448148148148,
    150.29111111111112,
    150.29407407407408,
    150.3274074074074,
    150.23888888888888,
    150.27555555555554,
    150.2625925925926,
    150.2674074074074,
    150.4051851851852,
    150.44,
    150.43185185185186,
    150.4574074074074,
    150.50925925925927,
    150.56851851851852,
    150.58185185185187,
    150.37740740740742,
    150.21777777777777,
    150.1062962962963,
    150.05333333333334,
    149.9488888888889,
    149.9611111111111,
    149.87185185185186,
    149.88962962962964,
    149.9814814814815,
    149.88962962962964,
    150.05777777777777,
    149.93185185185186,
    150.01962962962963,
    150.1811111111111,
    150.19296296296295,
    150.28222222222223,
    150.25629629629628,
    150.36666666666667,
    150.4462962962963,
    150.4188888888889,
    150.23407407407407,
    150.03666666666666,
    149.91555555555556,
    149.9185185185185,
    149.90666666666667,
    149.92111111111112,
    149.97074074074075,
    150.0762962962963,
    150.1025925925926,
    150.08407407407407,
    150.13074074074075,
    150.18296296296296,
    150.3188888888889,
    150.33925925925925,
    150.47296296296295,
    150.45185185185184,
    150.6337037037037,
    150.6674074074074,
    150.58407407407407,
    150.4814814814815,
    150.34555555555556,
    150.2462962962963,
    150.24592592592592,
    150.26703703703703,
    150.3537037037037,
    150.32925925925926,
    150.47222222222223,
    150.45592592592592,
    150.44592592592593,
    150.4911111111111,
    150.5811111111111,
    150.59740740740742,
    150.74851851851852,
    150.8262962962963,
    150.82333333333332,
    150.91555555555556,
    150.85703703703703,
    150.71740740740742,
    150.7488888888889,
    150.5074074074074,
    150.43259259259258,
    150.45407407407407,
    150.53,
    150.56037037037038,
    150.57592592592593,
    150.5837037037037,
    150.6437037037037,
    150.68185185185186,
    150.64222222222222,
    150.69333333333333,
    150.68851851851852,
    150.61666666666667,
    150.85518518518518,
    150.8451851851852,
    150.6851851851852,
    150.56703703703704,
    150.43296296296296,
    150.43407407407406,
    150.35703703703703,
    150.2625925925926,
    150.34962962962962,
    150.35777777777778,
    150.38925925925926,
    150.42518518518517,
    150.43,
    150.50814814814814,
    150.54444444444445,
    150.60518518518518,
    150.63074074074075,
    150.77962962962962,
    150.8151851851852,
    151.02925925925925,
    150.89851851851853,
    150.7462962962963,
    150.74962962962962,
    150.69962962962964,
    150.7937037037037,
    150.74666666666667,
    150.7474074074074,
    150.83481481481482,
    150.8237037037037,
    150.88111111111112,
    150.98814814814816,
    151.0511111111111,
    151.12259259259258,
    151.24185185185186,
    151.2985185185185,
    151.29185185185185,
    151.3925925925926,
    151.34,
    151.30851851851853,
    151.22666666666666,
    151.1937037037037,
    151.17851851851853,
    151.2337037037037,
    151.26111111111112,
    151.26185185185184,
    151.27407407407406,
    151.26296296296297,
    151.2577777777778,
    151.33851851851853,
    151.40222222222224,
    151.40259259259258,
    151.47222222222223,
    151.55074074074074,
    151.6462962962963,
    151.6548148148148,
    151.5785185185185,
    151.39037037037036,
    151.25629629629628,
    151.12185185185186,
    151.03074074074075,
    150.8388888888889,
    150.81037037037038,
    150.78,
    150.81259259259258,
    150.84777777777776,
    150.70074074074074,
    150.80555555555554,
    150.8011111111111,
    150.8637037037037,
    150.83074074074074,
    150.85666666666665,
    150.85962962962964,
    150.91962962962964,
    150.9425925925926,
    150.95703703703703,
    150.74703703703705,
    150.56333333333333,
    150.5085185185185,
    150.42407407407407,
    150.32555555555555,
    150.1822222222222,
    150.24666666666667,
    150.18259259259258,
    150.20185185185184,
    150.17037037037036,
    150.25518518518518,
    150.23851851851853,
    150.3651851851852,
    150.3759259259259,
    150.51111111111112,
    150.50666666666666,
    150.4525925925926,
    150.22555555555556,
    150.1114814814815,
    149.96851851851852,
    149.91,
    149.82925925925926,
    149.8014814814815,
    149.7974074074074,
    149.8137037037037,
    149.8574074074074,
    149.93407407407406,
    149.88592592592593,
    149.90333333333334,
    149.98703703703703,
    150.01444444444445,
    150.05555555555554,
    150.15074074074073,
    150.17703703703702,
    150.11703703703705,
    149.92444444444445,
    149.88777777777779,
    149.82296296296298,
    149.7337037037037,
    149.76481481481483,
    149.7574074074074,
    149.86481481481482,
    149.90925925925927,
    149.85,
    149.96296296296296,
    149.99481481481482,
    150.06666666666666,
    150.12962962962962,
    150.20037037037036,
    150.25518518518518,
    150.39925925925925,
    150.25444444444443,
    150.10407407407408,
    149.8188888888889,
    149.7414814814815,
    149.67814814814815,
    149.6688888888889,
    149.6911111111111,
    149.73111111111112,
    149.80296296296297,
    149.82703703703703,
    149.83296296296297,
    149.83962962962963,
    149.98925925925926,
    149.96037037037038,
    149.99037037037036,
    150.13037037037037,
    150.1414814814815,
    150.1451851851852]

//    func makeSineWaveOld() -> [Double] {
//        let sampleSize = 300
//        let stride1: vDSP_Stride = 1
////        let sampleLength = vDSP_Length(sampleSize)
//        var start: Double = 0
//        var increment: Double = 1
//        var ramp = Doubles( n:sampleSize )
//        vDSP_vrampD( &start, &increment, &ramp, stride1, vDSP_Length( sampleSize ) )
//        var data = Doubles(n:sampleSize)
//
//        data = ramp.map( { sin( $0 / 3 ) } )
////        var numbers : [Double] = []
////        numbers.append(10)
////        numbers.append(20)
////        numbers.append(25)
////        numbers.append(15)
////        numbers.append(13)
////
////        return numbers
//        return data
//    }
    func Doubles(n: Int)->[Double] {
        return [Double](repeating:0, count:n)
    }
    func makeTimeSeries() -> [Double]{
        let seconds = 10.0
        let n = 300
        let timeSeries = (0..<n).map{
            Double($0) * seconds/Double(n)
        }
        return timeSeries

    }
    static func makeSineWave( _ frequency:Double) -> [Double]{
        let n = 300 // Should be power of two for the FFT ??
        let amplitude = 1.0
        let seconds = 10.0
        let fps = Double(n)/seconds

        let sineWave = (0..<n).map {
            amplitude * sin(2.0 * .pi / fps * Double($0) * frequency)
        }
        return sineWave
    }
    func getSampleGreen() ->[Double]{
        let min = hrSampleGreen.min()!
        let range = hrSampleGreen.max()! - min
        let normalizedSamples = hrSampleGreen.map {($0-min)/range}
        return normalizedSamples
    }
    
}