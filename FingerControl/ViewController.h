//
//  ViewController.h
//  FingerControl
//
//  Created by Coco Ding on 3/27/15.
//  Copyright (c) 2015 Coco Ding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FingerTracker.h"
#import "HSVControlView.h"

@interface ViewController : NSViewController <FingerTrackerDelegate, HSVControlViewDelegate> {
    FingerTracker *_tracker;
    
//    IBOutlet NSSlider *_lowHSlider, *_highHSlider, *_lowSSlider, *_highSSlider, *_lowVSlider, *_highVSlider;
    
}

@property (nonatomic) int lowH, highH, lowS, highS, lowV, highV;

@property (atomic, strong) HSVControlView *view;

- (IBAction)updateRange:(id)sender;

@end

