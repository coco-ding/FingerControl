//
//  CursorController.h
//  fingerctl
//
//  Created by Coco Ding on 3/24/15.
//  Copyright (c) 2015 Coco Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface CursorController : NSObject {
    CGEventSourceRef evsrc;
}

+ (CursorController *)sharedController;

- (id)init;
- (void)moveCursorTo:(CGPoint)point;

@end
