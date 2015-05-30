//
//  CBDoubleTapAndPanGestureRecognizer.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CBDoubleTapAndPanZoomInDirection) {
    CBDoubleTapAndPanZoomInDirectionUp = 0,
    CBDoubleTapAndPanZoomInDirectionDown
};

@interface CBDoubleTapAndPanGestureRecognizer : UIGestureRecognizer

@property (nonatomic, assign) CBDoubleTapAndPanZoomInDirection direction;   // Default is moving up to zoom in
@property (nonatomic, assign) CGFloat scalePerPoint;                        // Default is +0.01x for each point
@property (nonatomic, assign) CGFloat timeoutInterval;                      // Default is 0.5 second
@property (nonatomic, assign) CGFloat offsetAllowed;                        // Max allowed distance between 1st tap and 2nd tap, default is 10 points

@property (nonatomic, readonly) CGFloat scale;                              // The scale value compared to the last UIGestureRecognizerStateChanged state

@end
