//
//  TemporalFilter.swift
//  
//
//  Created by Fred OLeary on 12/13/19.
//

import Foundation
import Accelerate
/*
 Note - The v_DSP. (dot) functions seem to be available only in ios 13 and later.
 */
// public func vDSP_DCT_CreateSetup(_ __Previous: vDSP_DFT_Setup?, _ __Length: vDSP_Length, _ __Type: vDSP_DCT_Type) -> vDSP_DFT_Setup?
class TemporalFilter {
    let sampleCount = 256
    var forwardDCTSetup: vDSP_DFT_Setup?
    var inverseDCTSetup: vDSP_DFT_Setup?
    var forwardDCT_PreProcessed: [Float]?
    var forwardDCT_PostProcessed: [Float]?
    var inverseDCT_Result: [Float]?
    let stride = vDSP_Stride(1)
    init(){
        forwardDCTSetup = vDSP_DCT_CreateSetup( nil, vDSP_Length(sampleCount),  vDSP_DCT_Type.II)
        inverseDCTSetup = vDSP_DCT_CreateSetup( nil, vDSP_Length(sampleCount),  vDSP_DCT_Type.III)
        forwardDCT_PreProcessed = [Float](repeating: 0, count: sampleCount)
        forwardDCT_PostProcessed = [Float](repeating: 0, count: sampleCount)
        inverseDCT_Result = [Float](repeating: 0, count: sampleCount)
    }

    // Multiplies the frequency-domain representation of `input` by
    // `dctMultiplier`, and returns the temporal-domain representation
    // of the product.
    func apply(dctMultiplier: [Float], toInput input: [Float]) -> [Float] {
        // Perform forward DCT.
        // forwardDCT?.transform(input, result: &forwardDCT_PreProcessed)
        vDSP_DCT_Execute(forwardDCTSetup!, input, &(forwardDCT_PreProcessed!))
        
        // Multiply frequency-domain data by `dctMultiplier`.
        // vDSP.multiply(dctMultiplier, forwardDCT_PreProcessed, result: &forwardDCT_PostProcessed)
        vDSP_vmul(dctMultiplier, stride, forwardDCT_PreProcessed!, stride, &(forwardDCT_PostProcessed!), stride, vDSP_Length(sampleCount))

        // Perform inverse DCT.
        // inverseDCT?.transform(forwardDCT_PostProcessed, result: &inverseDCT_Result)
        vDSP_DCT_Execute(inverseDCTSetup!, forwardDCT_PostProcessed!, &(inverseDCT_Result!))

//        // In-place scale inverse DCT result by n / 2.
//        // Output samples are now in range -1...+1
//        vDSP.divide(inverseDCT_Result, Float(sampleCount / 2), result: &inverseDCT_Result)
        var divisor = Float( sampleCount/2 )
        vDSP_vsdiv(inverseDCT_Result!, stride, &divisor, &(inverseDCT_Result!), stride, vDSP_Length(sampleCount))
        return inverseDCT_Result!
    }
    
    func makeBandpassFilterWithFcAndQ( _ filter: inout [Double], _ Fs:Double, _ Fc:Double, _ Q:Double) {
     
      // Fs = sampling rate, Fc = centre freq
      // with thanks to http://www.earlevel.com/main/2013/10/13/biquad-calculator-v2/
      // and https://github.com/bartolsthoorn/NVDSP
     
      let K:Double = tan(Double.pi * Fc / Fs)
      let norm:Double = 1.0 / (1.0 + K / Q + K * K)
      filter[0] = Double(K / Q * norm)
      filter[1] = 0.0
      filter[2] = -filter[0]
      filter[3] = Double(2.0 * (K * K - 1.0) * norm)
      filter[4] = Double((1.0 - K / Q + K * K) * norm)
    }
    
    func makeBandpassFilterWithFreqRange( _ filter: inout [Double], _ Fs:Double, _ Fbtm:Double, _ Ftop:Double) {
     
      // with thanks to
      // http://stackoverflow.com/questions/15627013/how-do-i-configure-a-bandpass-filter
      // -- this sets Q such that there's -3dB gain (= 50% power loss) at Fbtm and Ftop
     
        let Fc = sqrt(Fbtm * Ftop)
        
        let Q = Fc / (Ftop - Fbtm);
        makeBandpassFilterWithFcAndQ(&filter, Fs, Fc, Q);
    }
    
    func bandpassFilter( dataIn:[Double], sampleRate:Double, filterLoRate:Double, filterHiRate:Double ) -> [Double]{

        var inputFloats:[Float] = (0..<dataIn.count).map {
            return Float( dataIn[$0])
        }
        let dspFilter = DSPFilter()
        // testAPI.testIt(30, &data, 300, 0.74, 2.4)
        dspFilter.butterworthFilter( Int32(sampleRate), &inputFloats, 300, filterLoRate, filterHiRate )
        let output:[Double] = (0..<inputFloats.count).map {
            return Double( inputFloats[$0])
        }
        return output
        
        
//        var filter = [Double](repeating: 0, count: 5)
//        let stride = vDSP_Stride(1)
//        var filteredFloats = [Double](repeating: 0, count: dataIn.count)
//
//        makeBandpassFilterWithFreqRange( &filter, sampleRate, filterLoRate, filterHiRate);
//        vDSP_deq22D(dataIn, stride, filter, &filteredFloats, stride, vDSP_Length( filteredFloats.count - 2) );
//        return filteredFloats
    }
    func getFilterResponse( fps:Double, filterStart:Double, filterEnd:Double,  startFrequency:Double, endFrequency:Double ) ->([Double], [Double]){
        func getFilterResponseFreq( _ fps:Double, _ filterStart:Double, _ filterEnd:Double,  _ frequency:Double ) -> Double{
            let input = TestAccelerate.makeSineWave( frequency, fps:30, noOfSamples:300 )
            let output = bandpassFilter(dataIn: input, sampleRate: fps, filterLoRate: filterStart, filterHiRate: filterEnd)

            let outputFloats:[Float] = (0..<output.count).map {
                return Float( output[$0])
            }
            
//            let input = TestAccelerate.makeSineWave( frequency, fps:30, noOfSamples:300 )
//            var inputFloats:[Float] = (0..<input.count).map {
//                return Float( input[$0])
//            }
//            let dspFilter = DSPFilter()
//            // testAPI.testIt(30, &data, 300, 0.74, 2.4)
//            dspFilter.butterworthFilter( Int32(fps), &inputFloats, 300, filterStart, filterEnd )
            
            let stride = vDSP_Stride(1)
            let n = vDSP_Length(outputFloats.count)
            var rmsValue: Float = .nan
            vDSP_rmsqv(outputFloats, stride, &rmsValue, n)
            return Double( rmsValue )
        }

        let length = Int((endFrequency - startFrequency)/0.1)
        let response:[Double] = (0..<length).map {
            getFilterResponseFreq( fps, filterStart, filterEnd, startFrequency +  Double($0) * 0.1 )
        }
        let freqs:[Double] = (0..<length).map {
            startFrequency +  Double($0) * 0.1
        }
        return (response, freqs)
    }
}
