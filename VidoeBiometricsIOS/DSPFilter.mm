//
//  DSPFilter.m
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 2/12/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSPFilter.h"

#import "DspFilters/Dsp.h"
@implementation DSPFilter

- (void) butterworthFilter :(int)fps
:(float*) data
:(int)numSamples
:(double) lowFrequency
:(double) highFrequency;
{
    
    float* filterData[1];
    float centerFrequency = (lowFrequency + highFrequency)/2;
    float bandwidth = highFrequency - lowFrequency;
    
    filterData[0] = data;
    
//    Dsp::Filter* f = new Dsp::SmoothedFilterDesign<Dsp::Butterworth::Design::BandPass <5>, 1, Dsp::DirectFormII> (1024);
//    Dsp::Params params;
//    params[0] = fps; // sample rate
//    params[1] = 5; // order
//    params[2] = centerFrequency; // center frequency
//    params[3] = bandwidth; // band width
//    f->setParams (params);
//    f->process (numSamples, filterData);
//    delete f;

    Dsp::SimpleFilter<Dsp::Butterworth::BandPass <9>, 1> f;
    f.setup( 9, // Order
             fps, // Sample rate
             centerFrequency,
             bandwidth
            );
    f.process (numSamples, filterData);

}
@end

