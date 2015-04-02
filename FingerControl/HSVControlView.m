//
//  HSVControlView.m
//  FingerControl
//
//  Created by Coco Ding on 3/28/15.
//  Copyright (c) 2015 Coco Ding. All rights reserved.
//

#import "HSVControlView.h"

@implementation HSVControlView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)canBecomeKeyView
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    [super keyDown:theEvent];
    [self.delegate controlView:self keyDown:theEvent.charactersIgnoringModifiers];
}

@end
