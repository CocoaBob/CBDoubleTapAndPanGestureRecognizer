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
    CGPoint _firstPoint;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        _scalePerPoint = 0.01;
        _timeoutInterval = 0.5;
        _offsetAllowed = 10;
    }
    return self;
}

- (void)reset {
    [super reset];
    
    _scale = 1.0f;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self invalidateTimer];
    
    UITouch *touch = [touches anyObject];
    if ([touches count] == 1 && touch.tapCount == 1 && self.state == UIGestureRecognizerStatePossible) {
        _firstPoint = [touch locationInView:self.view];
        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:_timeoutInterval target:self selector:@selector(handleTimeOut) userInfo:nil repeats:NO];
    } else if ([touches count] == 1 && touch.tapCount == 2) {
        // Failed if touches are too distant
        CGPoint secondPoint = [touch locationInView:self.view];
        if (sqrt(pow(secondPoint.x - _firstPoint.x, 2) + pow(secondPoint.y - _firstPoint.y, 2)) > _offsetAllowed) {
            self.state = UIGestureRecognizerStateFailed;
        }
    } else if ([touches count] > 1 || touch.tapCount > 2) {
        // Failed if taps more than twice
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    [self invalidateTimer];
    
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        CGPoint point = [touch locationInView:self.view];
        CGPoint previousPoint = [touch previousLocationInView:self.view];
        CGFloat delta = previousPoint.y - point.y;
        
        if (_direction == CBDoubleTapAndPanZoomInDirectionUp) {
            _scale = 1.0f + delta * _scalePerPoint;
        } else if (_direction == CBDoubleTapAndPanZoomInDirectionDown) {
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
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    if (touches.count > 1 || touch.tapCount >= 2) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if (self.state == UIGestureRecognizerStatePossible) {
        // Do nothing
    } else if (self.state == UIGestureRecognizerStateBegan) {
        self.state = UIGestureRecognizerStateCancelled;
    } else if (self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateEnded;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [self invalidateTimer];
    
    if (self.state == UIGestureRecognizerStateBegan ||
        self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateCancelled;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

#pragma mark - Double tap timer

- (void)invalidateTimer {
    if (_timeOutTimer) {
        [_timeOutTimer invalidate];
        _timeOutTimer = nil;
    }
}

// Failed if the 1st tap takes too much time
// Failed if the 2nd tap comes too late
- (void)handleTimeOut {
    [self invalidateTimer];
    self.state = UIGestureRecognizerStateFailed;
}

@end
