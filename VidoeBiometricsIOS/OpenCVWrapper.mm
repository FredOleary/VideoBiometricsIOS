//
//  OpenCVWrapper.m
//  mac_min2
//
//  Created by Fred OLeary on 11/18/19.
//  Copyright © 2019 Fred OLeary. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import "OpenCVImageProcessor.h"
#import <UIKit/UIKit.h>

//CvVideoCamera* videoCamera;
//OpenCVImageProcessor* imageProcessor;


@implementation OpenCVWrapper{
    CvVideoCamera* videoCamera;
    OpenCVImageProcessor* imageProcessor;
    NSMutableArray* redPixels;
    NSMutableArray* greenPixels;
    NSMutableArray* bluePixels;
    double actualFps;
    int framesPerHRSample;
    int cameraFrameRate;
}

- (id) init {
    NSLog(@"OpenCVWrapper - Init");
    actualFps = 30.0;
    return self;
}

- (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

- (NSMutableArray*)getRedPixels{
    return redPixels;
}
- (NSMutableArray*)getGreenPixels{
    return greenPixels;
}
- (NSMutableArray*)getBluePixels{
    return bluePixels;
}
- (double)getActualFps{
    return actualFps;
}

- (UIImage *)loadImage: (NSString *)imageName{

    UIImage* resImage = [UIImage imageNamed:imageName];
    
    cv::Mat cvImage;
    UIImageToMat(resImage, cvImage);
    
    if( cvImage.data == NULL){
        return NULL;
    }else{
        cv::Mat gray;
        cv::cvtColor(cvImage, gray, cv::ColorConversionCodes::COLOR_RGB2GRAY);

        UIImage* outImage = MatToUIImage(gray);
        return outImage;
    }
}
- (BOOL)initializeCamera :(int)framesPerHeartRateSample :(int)frameRate{
    NSLog(@"OpenCVWrapper:initializeCamera Frame Rate: %d, Frames per Heart rate sample %d", frameRate, framesPerHeartRateSample);
    UIImageView *dummyImageView = [UIImageView alloc];
//    UIImageView *dummyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Trend"]];
    
    framesPerHRSample = framesPerHeartRateSample;
    cameraFrameRate = frameRate;
    imageProcessor = [[OpenCVImageProcessor alloc] initWithOpenCVView
//                      :imageOpenCV:heartRateLabel
//                      :heartRateProgress
                      :framesPerHRSample
                      :self];
    videoCamera = [[CvVideoCamera alloc] initWithParentView:dummyImageView];
    videoCamera.delegate = imageProcessor;
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    videoCamera.defaultFPS = cameraFrameRate;
    return true;
}

- (void) startCamera :(int)frameRate{
    NSLog(@"Video Started---");
    cameraFrameRate = frameRate;
    videoCamera.defaultFPS = cameraFrameRate;
    [videoCamera start];
}
- (void) stopCamera{
    NSLog(@"Video Stopped---");
    [videoCamera stop];
}
- (void) resumeCamera{
    NSLog(@"Video Resumed---");
    [imageProcessor resume];
}


- (void)framesProcessed:(int)frameCount :(NSMutableArray*) redPixelsIn :(NSMutableArray*) greenPixelsIn :(NSMutableArray*) bluePixelsIn :(double)fps
{
    NSLog(@"OpenCVWrapper:framesProcessed -%d, frames. FPS %f", frameCount, fps);
    actualFps = fps;
    redPixels = [[NSMutableArray alloc] initWithArray:redPixelsIn copyItems:YES];
    greenPixels = [[NSMutableArray alloc] initWithArray:greenPixelsIn copyItems:YES];
    bluePixels = [[NSMutableArray alloc] initWithArray:bluePixelsIn copyItems:YES];
    [redPixelsIn removeAllObjects];
    [greenPixelsIn removeAllObjects];
    [bluePixelsIn removeAllObjects];
    
    [self.delegate framesReady:imageProcessor.videoProcessingPaused: fps ];
}
    
- (void)frameReady:(UIImage*) frame :(float) heartRateProgress :(int) frameNumber
{
//    NSLog(@"OpenCVWrapper:frameReady");
    [self.delegate frameAvailable:frame :heartRateProgress :frameNumber];
}
@end
