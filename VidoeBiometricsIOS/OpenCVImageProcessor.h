//
//  OpenCVImageProcessor.h
//  mac_min2
//
//  Created by Fred OLeary on 11/20/19.
//  Copyright © 2019 Fred OLeary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/videoio/cap_ios.h>
#import "OpenCVWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVImageProcessor : NSObject<CvVideoCameraDelegate>

@property(nonatomic, weak)id <OpenCVImageProcessorDelegate> delegate;
@property (atomic) bool videoProcessingPaused;

- (id)initWithOpenCVView:(int)framesPerHRReading
                        :(id<OpenCVImageProcessorDelegate>)del;
- (void)processImage:(cv::Mat&)image;
- (bool)faceDetect: (cv::Mat&) image;
- (void)processImageRect :(cv::Mat&)image :(cv::Rect2d&) rect;
- (void)resume :(int)framesPerHeartRateReading;

+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
+(cv::Rect2d) clipRectToImage: (cv::Rect2d)clipRect :(cv::Mat&)image;

@end

NS_ASSUME_NONNULL_END
