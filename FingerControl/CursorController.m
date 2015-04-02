//
//  CursorController.m
//  fingerctl
//
//  Created by Coco Ding on 3/24/15.
//  Copyright (c) 2015 Coco Ding. All rights reserved.
//

#import "CursorController.h"
#import <Cocoa/Cocoa.h>

@implementation CursorController

CursorController *_cursorController = nil;

+ (CursorController *)sharedController {
    if (!_cursorController) {
        return ((_cursorController = [[self alloc] init]));
    }
    return _cursorController;
}

- (id)init {
    if ((self = [super init])) {
        evsrc = CGEventCreateSourceFromEvent(kCGEventSourceStateCombinedSessionState);
    }
    return self;
}

- (void)moveCursorTo:(CGPoint)point {
    
//    NSBezierPath
//    CAAnimation
    
    CGEventSourceSetLocalEventsSuppressionInterval(evsrc, 1);
    CGAssociateMouseAndMouseCursorPosition (0);
    CGWarpMouseCursorPosition(point);
    CGAssociateMouseAndMouseCursorPosition (1);
}

@end
