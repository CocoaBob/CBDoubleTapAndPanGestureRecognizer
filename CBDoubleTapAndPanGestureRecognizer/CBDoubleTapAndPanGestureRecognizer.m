//
//  CBDoubleTapAndPanGestureRecognizer.m
//
//  Created by CocoaBob on 07/24/13.
//  Copyright (c) 2013 CocoaBob. All rights reserved.
//
//  Inspired by GestureRecognizerSample, special thanks to KAKEGAWA Atsushi
//  https://github.com/kakegawa-atsushi/GestureRecognizerSample
//
//  Get the latest version from here:
//  https://github.com/CocoaBob/CBDoubleTapAndPanGestureRecognizer
//
//  iOS 5.0+ and ARC are Required.
//
//  Distributed under the MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the “Software”), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "CBDoubleTapAndPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation CBDoubleTapAndPanGestureRecognizer {
    NSTimer *_timeOutTimer;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        _scalePerPoint = 0.01;
    }
    return self;
}

- (void)reset {
    _scale = 1.0f;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self invalidateTimer];
    if ([touches count] > 1) {
        self.state = UIGestureRecognizerStateFailed;
    } else {
        UITouch *touch = [touches anyObject];
        if (touch.tapCount == 1) {
            _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(handleTimeOut) userInfo:nil repeats:NO];
        } else if (touch.tapCount == 2) {
            return;
        } else {
            self.state = UIGestureRecognizerStateFailed;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self invalidateTimer];
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        CGPoint point = [touch locationInView:nil];
        CGPoint previousPoint = [touch previousLocationInView:nil];
        CGFloat delta = 0;
        if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
            switch ([[UIApplication sharedApplication] statusBarOrientation]) {
                case UIInterfaceOrientationLandscapeLeft:
                    delta = previousPoint.x - point.x;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    delta = point.x - previousPoint.x;
                    break;
                case UIInterfaceOrientationPortrait:
                    delta = previousPoint.y - point.y;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    delta = point.y - previousPoint.y;
                    break;
                default:
                    break;
            }
        }
        else {
            delta = previousPoint.y - point.y;
        }
        if (_direction == CBDoubleTapAndPanZoomInDirectionUp) {
            _scale = 1.0f + delta * _scalePerPoint;
        }
        else if (_direction == CBDoubleTapAndPanZoomInDirectionDown) {
            _scale = 1.0f - delta * _scalePerPoint;
        }
        
        if (self.state == UIGestureRecognizerStatePossible) {
            self.state = UIGestureRecognizerStateBegan;
        } else {
            self.state = UIGestureRecognizerStateChanged;
        }
    }
    else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self invalidateTimer];
    UITouch *touch = [touches anyObject];
    if (self.state == UIGestureRecognizerStatePossible &&
        touch.tapCount < 2) {
        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(handleTimeOut) userInfo:nil repeats:NO];
    }
    else {
        if (self.state == UIGestureRecognizerStateBegan ||
            self.state == UIGestureRecognizerStateChanged) {
            self.state = UIGestureRecognizerStateEnded;
        } else {
            self.state = UIGestureRecognizerStateFailed;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self invalidateTimer];
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)invalidateTimer {
    if (_timeOutTimer) {
        [_timeOutTimer invalidate];
        _timeOutTimer = nil;
    }
}

- (void)handleTimeOut {
    [self invalidateTimer];
    self.state = UIGestureRecognizerStateFailed;
}

@end
