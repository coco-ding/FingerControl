//
//  FingerTracker.h
//  FingerControl
//
//  Created by Coco Ding on 3/27/15.
//  Copyright (c) 2015 Coco Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import <vector>


typedef struct _HSVRange {
    int lowH;
    int highH;
    int lowS;
    int highS;
    int lowV;
    int highV;
} HSVRange;

@protocol FingerTrackerDelegate <NSObject>

- (void)fingerPositionChanged:(CGPoint)position cameraSize:(CGSize)size;

@end

@interface FingerTracker : NSObject {
    HSVRange _range;
    cv::VideoCapture *_camCap;
    NSTimer *_trackingTimer;
    cv::Rect _patternRect;
}

@property (atomic) HSVRange range;
@property (atomic) CGPoint fingerPosition;
@property (readonly) BOOL isPatternLoaded;
@property (unsafe_unretained) id<FingerTrackerDelegate> delegate;

- (id)initWithHSVRange:(HSVRange)range patternFile:(NSString *)path;

- (BOOL)startTracking;
- (BOOL)stopTracking;
- (void)writeContourToFile:(NSString *)path;

@end
