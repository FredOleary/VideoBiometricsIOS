//
//  DSPFilter.h
//  VidoeBiometricsIOS
//
//  Created by Fred OLeary on 2/12/20.
//  Copyright © 2020 Fred OLeary. All rights reserved.
//

#ifndef DSPFilter_h
#define DSPFilter_h


#endif /* DSPFilter_h */

@interface DSPFilter : NSObject
- (void) butterworthFilter :(int)fps
                :(float*) data
                :(int)numSamples
                :(double) lowFrequency
                :(double) highFrequency;

@end
