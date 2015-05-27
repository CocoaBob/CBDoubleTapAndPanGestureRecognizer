//
//  CBViewController.m
//  CBDoubleTapAndPanGestureRecognizerDemo
//
//  Created by CocoaBob on 29/07/13.
//  Copyright (c) 2013 CocoaBob. All rights reserved.
//

#import "DemoViewController.h"

#import "CBDoubleTapAndPanGestureRecognizer.h"

@interface DemoViewController () <UIScrollViewDelegate>

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIScrollView *scrollView;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set Scroll View
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.frame = self.view.frame;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.backgroundColor = [UIColor grayColor];
    self.view = self.scrollView;
    
    // Add Image View
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FrenchCountryside.jpg"]];
    [self.scrollView addSubview:self.imageView];
    
    [self updateMinMaxZoomScales];
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    
    // Gestures
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:singleTapGestureRecognizer];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapGestureRecognizer];
    
    CBDoubleTapAndPanGestureRecognizer *doubleTapAndPanGestureRecognizer = [[CBDoubleTapAndPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapAndPanGesture:)];
    doubleTapAndPanGestureRecognizer.direction = CBDoubleTapAndPanZoomInDirectionDown;
    doubleTapAndPanGestureRecognizer.scalePerPoint = 0.005;
    [self.scrollView addGestureRecognizer:doubleTapAndPanGestureRecognizer];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapAndPanGestureRecognizer];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    BOOL wasMinZoomScale = (self.scrollView.zoomScale == self.scrollView.minimumZoomScale);
    [self updateMinMaxZoomScales];
    if (wasMinZoomScale || self.scrollView.zoomScale < self.scrollView.minimumZoomScale) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    }
}

- (void)viewWillLayoutSubviews {
    CGPoint newCenter;
    newCenter.x = MAX(CGRectGetWidth(self.imageView.frame), CGRectGetWidth(self.scrollView.bounds)) / 2.0f;
    newCenter.y = MAX(CGRectGetHeight(self.imageView.frame), CGRectGetHeight(self.scrollView.bounds)) / 2.0f;
    self.imageView.center = newCenter;
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark Gestures

- (void)handleSingleTapGesture:(id)sender {
    BOOL statusBarWasHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:!statusBarWasHidden withAnimation:UIStatusBarAnimationFade];
}

- (void)handleDoubleTapGesture:(id)sender {
	CGPoint newCenter = [(UIGestureRecognizer *)sender locationInView:self.imageView];
    CGFloat newZoomScale;
    if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
        newZoomScale = self.scrollView.maximumZoomScale / 2.0f;
    } else {
        newZoomScale = pow(2, floor(log2(self.scrollView.zoomScale))) * 2.0f;
    }
    
    CGSize newSize;
    newSize.width = CGRectGetWidth(self.scrollView.bounds) / newZoomScale;
    newSize.height = CGRectGetHeight(self.scrollView.bounds) / newZoomScale;
    
    CGRect newRect;
    newRect.origin.x = newCenter.x - newSize.width / 2.0f;
    newRect.origin.y = newCenter.y - newSize.height / 2.0f;
    newRect.size = newSize;

    [self.scrollView zoomToRect:newRect animated:YES];
}

- (void)handleDoubleTapAndPanGesture:(id)sender {
    CBDoubleTapAndPanGestureRecognizer *gesture = sender;
    self.scrollView.zoomScale *= gesture.scale;
}

#pragma mark -

- (void)updateMinMaxZoomScales {
    CGFloat minWidthScale = CGRectGetWidth(self.scrollView.bounds) / CGRectGetWidth(self.imageView.bounds);
    CGFloat minHeightScale = CGRectGetHeight(self.scrollView.bounds) / CGRectGetHeight(self.imageView.bounds);
    self.scrollView.minimumZoomScale = MIN(minWidthScale, minHeightScale);
    self.scrollView.maximumZoomScale = 1;
}

@end
