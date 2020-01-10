//
//  OpenCVWrapper.h
//  mac_min2
//
//  Created by Fred OLeary on 11/18/19.
//  Copyright © 2019 Fred OLeary. All rights reserved.
// NO C++ files allowed here ONLY objective C
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#ifdef __cplusplus
//    #import <opencv2/videoio/cap_ios.h>
//#endif

//@protocol CvVideoCameraDelegate <NSObject>
//#ifdef __cplusplus
//// delegate method for processing image frames
//- (void)processImage:(UIImageView *)image;
//#endif
//
//@end

//@class FooCvVideoCamera;
//
//@protocol CvVideoCameraDelegate <NSObject>
//
//#ifdef __cplusplus
//// delegate method for processing image frames
//- (void)processImage:(void*)image;
//#endif
//
//@end

NS_ASSUME_NONNULL_BEGIN

@protocol OpenCVWrapperDelegate <NSObject>
- (void)framesReady:(bool)videoProcessingPaused;
- (void)frameAvailable:(UIImage*) frame;
@end

@protocol OpenCVImageProcessorDelegate <NSObject>
- (void)framesProcessed:(int)frameCount
                       :(NSMutableArray*) redPixels
                       :(NSMutableArray*) greenPixelsIn
                       :(NSMutableArray*) bluePixelsIn
                       :(double)fps;

- (void)frameReady: (UIImage*) frame;
                        
@end

@interface OpenCVWrapper : NSObject<OpenCVImageProcessorDelegate>

@property(nonatomic, weak)id <OpenCVWrapperDelegate> delegate;

- (id) init;

- (NSString *)openCVVersionString;
- (UIImage *)loadImage: (NSString *)imageName;
- (BOOL)initializeCamera: (int)framesPerHeartRateSample;

- (void) startCamera;
- (void) stopCamera;
- (void) resumeCamera;

- (NSMutableArray*)getRedPixels;
- (NSMutableArray*)getGreenPixels;
- (NSMutableArray*)getBluePixels;
- (double)getActualFps;


@end

NS_ASSUME_NONNULL_END
