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

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set Scroll View
    self.scrollView = [DemoScrollView new];
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
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    
    CBDoubleTapAndPanGestureRecognizer *doubleTapAndPanGestureRecognizer = [[CBDoubleTapAndPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapAndPanGesture:)];
    doubleTapAndPanGestureRecognizer.direction = CBDoubleTapAndPanZoomInDirectionDown;
    doubleTapAndPanGestureRecognizer.scalePerPoint = 0.005;
    [self.scrollView addGestureRecognizer:doubleTapAndPanGestureRecognizer];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapAndPanGestureRecognizer];
    [doubleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapAndPanGestureRecognizer];
}

// For iOS < 8.0
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    BOOL wasMinZoomScale = (self.scrollView.zoomScale == self.scrollView.minimumZoomScale);
    [self updateMinMaxZoomScales];
    if (wasMinZoomScale || self.scrollView.zoomScale < self.scrollView.minimumZoomScale) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    }
}

// For iOS >= 8.0
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    BOOL wasMinZoomScale = (self.scrollView.zoomScale == self.scrollView.minimumZoomScale);
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateMinMaxZoomScales];
        if (wasMinZoomScale || self.scrollView.zoomScale < self.scrollView.minimumZoomScale) {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        }
    } completion:nil];
}
#endif

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - Handle Gestures

- (void)handleSingleTapGesture:(id)sender {
    BOOL statusBarWasHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:!statusBarWasHidden withAnimation:UIStatusBarAnimationFade];
}

- (void)handleDoubleTapGesture:(id)sender {
	CGPoint newCenter = [(UIGestureRecognizer *)sender locationInView:self.imageView];
    
    CGFloat newZoomScale;
    if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
        newZoomScale = self.scrollView.minimumZoomScale;
    } else {
        newZoomScale = pow(2, floor(log2(self.scrollView.zoomScale))) * 2.0f;
    }
    
    CGSize newSize = self.scrollView.bounds.size;
    newSize.width /= newZoomScale;
    newSize.height /= newZoomScale;
    
    CGRect newRect;
    newRect.origin.x = newCenter.x - newSize.width / 2.0f;
    newRect.origin.y = newCenter.y - newSize.height / 2.0f;
    newRect.size = newSize;

    [self.scrollView zoomToRect:newRect animated:YES];
}

- (void)handleDoubleTapAndPanGesture:(CBDoubleTapAndPanGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            // Expand the range of zoom scale to support bounce
            self.scrollView.minimumZoomScale /= 2.0f;
            self.scrollView.maximumZoomScale *= 2.0f;
                break;
        }
        case UIGestureRecognizerStateChanged:
        {
            self.scrollView.zoomScale *= gestureRecognizer.scale;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            // Restore the original min/max zoom scales
            self.scrollView.minimumZoomScale *= 2.0f;
            self.scrollView.maximumZoomScale /= 2.0f;
            
            // Bounce back
            if (self.scrollView.zoomScale < self.scrollView.minimumZoomScale) {
                [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
            } else if (self.scrollView.zoomScale > self.scrollView.maximumZoomScale) {
                [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Routines

- (void)updateMinMaxZoomScales {
    CGFloat minWidthScale = CGRectGetWidth(self.scrollView.bounds) / CGRectGetWidth(self.imageView.bounds);
    CGFloat minHeightScale = CGRectGetHeight(self.scrollView.bounds) / CGRectGetHeight(self.imageView.bounds);
    self.scrollView.minimumZoomScale = MIN(minWidthScale, minHeightScale);
    self.scrollView.maximumZoomScale = 1;
}

@end

@implementation DemoScrollView

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
    [self centerContentView];
}

- (void)centerContentView {
    if ([self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        UIView *contentView = [self.delegate viewForZoomingInScrollView:self];
        
        CGPoint newCenter;
        newCenter.x = MAX(CGRectGetWidth(contentView.frame), CGRectGetWidth(self.bounds)) / 2.0f;
        newCenter.y = MAX(CGRectGetHeight(contentView.frame), CGRectGetHeight(self.bounds)) / 2.0f;
        contentView.center = newCenter;
    }
}

@end
