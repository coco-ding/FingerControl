//
//  ViewController.m
//  FingerControl
//
//  Created by Coco Ding on 3/27/15.
//  Copyright (c) 2015 Coco Ding. All rights reserved.
//

#import "ViewController.h"
#import "CursorController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.view.delegate = self;
    
    self.lowH = 175;
    self.highH = 179;
    self.lowS = 182;
    self.highS = 255;
    self.lowV = 80;
    self.highV = 255;
    
    HSVRange range = {_lowH, _highH, _lowS, _highS, _lowV, _highV};
    NSString *path = [[NSBundle mainBundle] pathForResource:@"pattern" ofType:@"dat"];
    _tracker = [[FingerTracker alloc] initWithHSVRange:range patternFile:path];
    _tracker.delegate = self;
    [_tracker startTracking];
    
}

- (void)controlView:(HSVControlView *)view keyDown:(NSString *)keys
{
    if (keys.length != 1) return;
    
//    void (^handleKeytroke)(NSCharacterSet *keySet, int *lowValue, int *highValue) = ^(NSCharacterSet *keySet, int *lowValue, int *highValue) {
//        if ([keySet characterIsMember:'-']) (*lowValue)--;
//        else if ([keySet characterIsMember:'=']) (*lowValue)++;
//        else if ([keySet characterIsMember:'[']) (*highValue)--;
//        else if ([keySet characterIsMember:']']) (*highValue)++;
//        [self updateRange:nil];
//    };
    
    char key = [keys characterAtIndex:0];
    switch (key) {
        case '1':
            self.lowH++;
            break;
        case 'q':
            self.lowH--;
            break;
        case '2':
            self.highH++;
            break;
        case 'w':
            self.highH--;
            break;
        case '3':
            self.lowS++;
            break;
        case 'e':
            self.lowS--;
            break;
        case '4':
            self.highS++;
            break;
        case 'r':
            self.highS--;
            break;
        case '5':
            self.lowV++;
            break;
        case 't':
            self.lowV--;
            break;
        case '6':
            self.highV++;
            break;
        case 'y':
            self.highV--;
            break;
        case 's': {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"pattern" ofType:@"dat"];
            [_tracker writeContourToFile:path];
            break;
        }
        default:
            return;
    }
    
    [self updateRange:nil];
}

- (IBAction)updateRange:(id)sender {
    _tracker.range = {self.lowH, self.highH, self.lowS, self.highS, self.lowV, self.highV};
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)fingerPositionChanged:(CGPoint)position cameraSize:(CGSize)size {
    
    CGSize screenSize = [NSScreen mainScreen].frame.size;
//    NSLog(@"screenX = %f, screenY = %f", screenSize.width, screenSize.height);
    CGPoint mappedPosition;
    mappedPosition.x = screenSize.width - position.x * (screenSize.width / size.width);
    mappedPosition.y = position.y * (screenSize.height / size.height);
//    NSLog(@"mappedPosX = %f, mappedPosY = %f", mappedPosition.x, mappedPosition.y);
    
    [[CursorController sharedController] moveCursorTo:mappedPosition];
}

@end
