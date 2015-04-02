//
//  FingerTracker.m
//  FingerControl
//
//  Created by Coco Ding on 3/27/15.
//  Copyright (c) 2015 Coco Ding. All rights reserved.
//

#import "FingerTracker.h"
#import "DisplacementFilter.h"

#import <vector>

using namespace cv;
using namespace std;

@interface FingerTracker () {
    int _lastX;
    int _lastY;
}

- (Mat)processOriginalImage:(Mat)originalImage;
- (void)updateFingerPosition;

@end

@implementation FingerTracker

@synthesize range = _range;

- (id)initWithHSVRange:(HSVRange)range
{
    if ((self = [super init])) {
        _range = range;
        _lastX = -1;
        _lastY = -1;
        
        // capture video form the camera, all the real time video stored in a VideoCapture cap
        _camCap = new VideoCapture(0);
        if (!_camCap->isOpened()) {
            NSLog(@"Cannot open the web cam.");
            return nil;
        }
    }
    return self;
}

- (Mat)processOriginalImage:(Mat)originalImage {
    // image process
    // 1. threshold the image
    Mat imgThresholded;
    inRange(originalImage, Scalar(_range.lowH, _range.lowS, _range.lowV), Scalar(_range.highH, _range.highS, _range.highV), imgThresholded);
    // 2. morphological opening (remove small object from the foreground
    erode(imgThresholded, imgThresholded, getStructuringElement(MORPH_ELLIPSE, cv::Size(5, 5)) );
    dilate( imgThresholded, imgThresholded, getStructuringElement(MORPH_ELLIPSE, cv::Size(5, 5)) );
    // 3. morphologrical closing (remove small holes from the foreground
    dilate( imgThresholded, imgThresholded, getStructuringElement(MORPH_ELLIPSE, cv::Size(5, 5)) );
    erode(imgThresholded, imgThresholded, getStructuringElement(MORPH_ELLIPSE, cv::Size(5, 5)) );
    return imgThresholded;
}

- (BOOL)startTracking {
    //[[CursorController sharedController] moveCursorTo:CGPointMake(100, 100)];
    
    // capture a temporary image from the camera: to creat a black image with the same size
    // Mat tempImg;
    // camCap.read(tempImg);
    
    // for loop
//    int cLastX = -1;
//    int cLastY = -1;
    
    namedWindow("Thresholded Image", WINDOW_NORMAL);
    
    [NSThread detachNewThreadSelector:@selector(trackingLoop) toTarget:self withObject:nil];
    
//    [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(trackingLoop) userInfo:nil repeats:YES];
//    _trackingTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(trackingLoop) userInfo:nil repeats:YES];
    
    return YES;
}

- (BOOL)stopTracking {
//    [_trackingTimer invalidate];
    [NSThread exit];
    destroyAllWindows();
    return YES;
}

- (void)trackingLoop {
    // capture a temporary image from the camera: to creat a black image with the same size
    // Mat tempImg;
    // camCap.read(tempImg);
    
    // for loop
    DisplacementFilter filter(4);
    Mat imgThresholded;
    while (1) {
        // read a new frame from video
        Mat imgOriginal;
        bool cSuccuess = _camCap->read(imgOriginal);
        if (!cSuccuess) {
            NSLog(@"Cannot read a frame from video");
            return;
        }
        
        // transfer to HSV image
        Mat imgHSV;
        cvtColor(imgOriginal, imgHSV, COLOR_BGR2HSV);
        
        // image processing
        imgThresholded = [self processOriginalImage:imgHSV];
        
        // calcualte the moments of the images and get the position of taget
        Moments cMoments = moments(imgThresholded);
        double cM10 = cMoments.m10;
        double cM01 = cMoments.m01;
        double cArea = cMoments.m00;
        
        if (cArea > 10000) {
            float posX = cM10 / cArea;
            float posY = cM01 / cArea;
            bool integlFlag = filter.validateDisplacement(CGPointMake(posX, posY));
            // integl
            if (integlFlag) {
                NSLog(@"posX = %f, posY = %f", posX, posY);
                _fingerPosition = CGPointMake(posX, posY);
                //                [self updateFingerPosition];
                [self performSelectorOnMainThread:@selector(updateFingerPosition) withObject:self waitUntilDone:NO];
            }
        }
        
        Mat dispImg;
        cv::Size newSize((int)(400*1.77778), 400);
        resize(imgThresholded, dispImg, newSize, 0, 0, INTER_LINEAR);
        imshow("Thresholded Image", dispImg);
        resizeWindow("Thresholded Image", 400 * 1.77778, 400);
        moveWindow("Thresholded Image", 0, 0);
        //        namedWindow("Original, Imgae", WINDOW_NORMAL);
        //        imshow("Original Image", imgOriginal);
    }
}

- (void)updateFingerPosition
{
    [self.delegate fingerPositionChanged:_fingerPosition cameraSize:CGSizeMake(1280, 720)];
}

@end
