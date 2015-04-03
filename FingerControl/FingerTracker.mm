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
    cv::Rect _currentRect;
}

- (Mat)processOriginalImage:(Mat)originalImage;
- (void)updateFingerPosition;
- (vector<cv::Rect>)rectanglesFromThresholdedImage:(Mat)imgThresholded;

@end


@implementation FingerTracker

@synthesize range = _range;

- (id)initWithHSVRange:(HSVRange)range patternFile:(NSString *)path
{
    if ((self = [super init])) {
        _range = range;
        
        NSData *rectData = [NSData dataWithContentsOfFile:path];
        if (rectData == nil) _isPatternLoaded = NO;
        else {
            cv::Rect *rect = (cv::Rect *)rectData.bytes;
            _patternRect = *rect;
            _isPatternLoaded = YES;
        }
        
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

- (vector<cv::Rect>)rectanglesFromThresholdedImage:(Mat)imgThresholded
{
    Mat canny_output;
    Mat blur_output;
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    int thresh = 100;
    RNG rng(12345);
    
    
    // blur image
    blur(imgThresholded, blur_output, cv::Size(2,2));
    /// Detect edges using canny
    Canny( blur_output, canny_output, thresh, thresh*2, 3 );
    /// Find contours
    findContours( canny_output, contours, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    vector<vector<cv::Point>> contours_poly(contours.size());
    vector<cv::Rect> boundRects(contours.size());
    
    if (contours.empty()) return boundRects;
    
    /// Approximate contours to polygons + get bounding rects and circles
    for( int i = 0; i < contours.size(); i++ ){
        approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
        boundRects[i] = boundingRect( Mat(contours_poly[i]) );
    }
    
    // connect rect
    for (int i = 1; i < contours.size(); i++) {
        if ( (abs((boundRects[i].x - boundRects[i-1].x)) < 20) || (abs((boundRects[i].y - boundRects[i-1].y)) < 20)) {
            boundRects[i] = boundRects[i-1] | boundRects[i];
        }
    }
    if (boundRects.size() >= 2) {
        if ( (abs((boundRects[1].x - boundRects[0].x)) < 20) || (abs((boundRects[1].y - boundRects[0].y)) < 20)){
            boundRects[0] = boundRects[0] | boundRects[1];
        }
    }
    
    /// Draw polygonal contour + bonding rects
    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
    int maxRectIndex = 0;
    if (boundRects.size() >= 2) {
        for (int i = 1; i< boundRects.size(); i++ ) {
            //        drawContours( drawing, contours_poly, i, color, 1, 8, vector<Vec4i>(), 0, cv::Point() );
            if (boundRects[i].width * boundRects[i].height > boundRects[i-1].width * boundRects[i-1].height)
                maxRectIndex = i;
        }
    }
    _currentRect = boundRects[maxRectIndex];
    
    Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
    rectangle( drawing, boundRects[maxRectIndex].tl(), boundRects[maxRectIndex].br(), color, 2, 8, 0 );
   
    /// Draw contours
//    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
    /*
    for( int i = 0; i< contours.size(); i++ )
    {
        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
    }
    */
    /// Show in a window
    Mat dispImg1;
    cv::Size newSize((int)(400*1.77778), 400);
    resize(drawing, dispImg1, newSize, 0, 0, INTER_LINEAR);
    imshow("Contour Image", dispImg1);
    resizeWindow("Contour Image", 400 * 1.77778, 400);
    moveWindow("Contour Image", 800, 0);
    
    return boundRects;
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
//        NSData *momentsData= [NSData dataWithContentsOfFile:@"pattern_moments.dat"];
//        Moments *patternMoments = (Moments *)momentsData.bytes;
        // find contours
        
        vector<cv::Rect> rects = [self rectanglesFromThresholdedImage:imgThresholded];
        if (rects.empty()) continue;
        NSLog(@"rect[0]: %d %d %d %d", rects[0].x, rects[0].y, rects[0].width, rects[0].height);
        
        cv::Rect *targetRect = NULL;
        if (_isPatternLoaded) {
            for (int i = 0; i < rects.size(); i++) {
                if ( (abs(rects[i].x - _patternRect.x) < 100) && (abs(rects[i].y - _patternRect.y) < 100) ) {
                    targetRect = &rects[i];
                    break;
                }
            }
            if (!targetRect) continue;
        }
        else {
            targetRect = &_currentRect;
        }
        // using the target rect to compute course position
        float posX = 0.0;
        float posY = 0.0;
        if (targetRect->width * targetRect->height > 1000) {
            posX = targetRect->x + targetRect->width / 2;
            posY = targetRect->y + targetRect->height / 2;
            
            bool integlFlag = filter.validateDisplacement(CGPointMake(posX, posY));
            // integl
            if (integlFlag) {
                NSLog(@"posX = %f, posY = %f", posX, posY);
                _fingerPosition = CGPointMake(posX, posY);
                //                [self updateFingerPosition];
                [self performSelectorOnMainThread:@selector(updateFingerPosition) withObject:self waitUntilDone:NO];
            }
        }
 
        
#if 0
        Moments cMoments;
        if (_isPatternLoaded) {
            int targetIndex = 0;
            for (int i = 0; i < contoursList.size(); i++) {
                double similarityCoefficient = cv::matchShapes(*_patternContour, contoursList[i], CV_CONTOURS_MATCH_I1, 0.0);
                if (similarityCoefficient < 0.0001){
                    targetIndex = i;
                    break;
                }
            }
        // calcualte the moments of the images and get the position of taget
//        Moments cMoments = moments(imgThresholded);
            cMoments = moments(contoursList[targetIndex]);
        } else {
            cMoments = moments(imgThresholded);
        }
        
        
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
#endif
        
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

- (void)writeContourToFile:(NSString *)path
{
    NSData *contourData = [NSData dataWithBytes:&_currentRect length:sizeof(_currentRect)];
    [contourData writeToFile:path atomically:YES];
    _patternRect = _currentRect;
    _isPatternLoaded = YES;
}

@end
