//
//  HSVControlView.h
//  FingerControl
//
//  Created by Coco Ding on 3/28/15.
//  Copyright (c) 2015 Coco Ding. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HSVControlView;

@protocol HSVControlViewDelegate <NSObject>

- (void)controlView:(HSVControlView *)view keyDown:(NSString *)keys;

@end

@interface HSVControlView : NSView

@property (nonatomic, unsafe_unretained) id<HSVControlViewDelegate> delegate;

@end
