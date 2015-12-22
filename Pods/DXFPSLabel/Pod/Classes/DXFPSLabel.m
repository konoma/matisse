//
//  DXFPSLabel.m
//
//  Created by xiekw on 10/27/14.
//  Copyright (c) 2014 xiekw. All rights reserved.
//

#import "DXFPSLabel.h"

@interface DXFPSLabel ()
{
    CADisplayLink *_displayLink;
    NSInteger _framesInLastInterval;
    CFAbsoluteTime _lastLogTime;
    NSInteger _totalFrames;
    NSTimeInterval _scrollingTime;
    CGFloat _averageFPS;
}

@property (nonatomic, assign, readwrite) CGFloat averageFPS;

@end

@implementation DXFPSLabel

+ (void)showInWindow:(UIWindow *)window {
    CGRect windowFrame = window.frame;
    if (CGRectIsEmpty(windowFrame)) {
        NSLog(@"==== DXFPSLabel ==== shows in a CGRectZero window");
        return;
    }
    CGRect leftDownCorner = CGRectMake(0, CGRectGetHeight(windowFrame) - 40, 80, 40);
    DXFPSLabel *label = [[DXFPSLabel alloc] initWithFrame:leftDownCorner];
    [window addSubview:label];
}

- (void)dealloc {
    [_displayLink invalidate];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor blackColor];
    
    [self _scrollingStatusDidChange];
    [self resetScrollingPerformanceCounters];
    
    [self addObserver:self forKeyPath:@"averageFPS" options:NSKeyValueObservingOptionNew context:NULL];

    return self;
}

#pragma mark - Monitoring Scrolling Performance

- (void)resetScrollingPerformanceCounters {
    _framesInLastInterval = 0;
    _lastLogTime = CFAbsoluteTimeGetCurrent();
    _scrollingTime = 0;
    _totalFrames = 0;
}

- (void)_scrollingStatusDidChange {
    NSString *currentRunLoopMode = [[NSRunLoop currentRunLoop] currentMode];
    BOOL isScrolling = [currentRunLoopMode isEqualToString:UITrackingRunLoopMode];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_scrollingStatusDidChange) object:nil];
    
    if (isScrolling) {
        if (_displayLink == nil) {
            _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_screenDidUpdateWhileScrolling:)];
            [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:UITrackingRunLoopMode];
        }
        
        _framesInLastInterval = 0;
        _lastLogTime = CFAbsoluteTimeGetCurrent();
        [_displayLink setPaused:NO];
        
        // Let us know when scrolling has stopped
        [self performSelector:@selector(_scrollingStatusDidChange) withObject:nil afterDelay:0 inModes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    } else {
        [_displayLink setPaused:YES];
        
        // Let us know when scrolling begins
        [self performSelector:@selector(_scrollingStatusDidChange) withObject:nil afterDelay:0 inModes:[NSArray arrayWithObject:UITrackingRunLoopMode]];
    }
}

- (void)_screenDidUpdateWhileScrolling:(CADisplayLink *)displayLink {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    if (!_lastLogTime) {
        _lastLogTime = currentTime;
    }
    CGFloat delta = currentTime - _lastLogTime;
    if (delta >= 1) {
        _scrollingTime += delta;
        _totalFrames += _framesInLastInterval;
        CGFloat averageFPS = (CGFloat)(_totalFrames / _scrollingTime);
        [self setAverageFPS:averageFPS];
        
        _framesInLastInterval = 0;
        _lastLogTime = currentTime;
    } else {
        _framesInLastInterval++;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"averageFPS"]) {
        CGFloat averageFPS = [[change valueForKey:NSKeyValueChangeNewKey] floatValue];
        averageFPS = MIN(MAX(0, averageFPS), 60);
        [self _displayAverageFPS:averageFPS];
    }
}

- (void)_displayAverageFPS:(CGFloat)averageFPS {
    if ([self attributedText] == nil) {
        CATransition *fadeTransition = [CATransition animation];
        [[self layer] addAnimation:fadeTransition forKey:kCATransition];
    }
    
    NSString *averageFPSString = [NSString stringWithFormat:@"%.0f", averageFPS];
    NSUInteger averageFPSStringLength = [averageFPSString length];
    NSString *displayString = [NSString stringWithFormat:@"%@ FPS", averageFPSString];
    
    UIColor *averageFPSColor = [UIColor blackColor];
    
    if (averageFPS > 45) {
        averageFPSColor = [UIColor colorWithHue:(114 / 359.0) saturation:0.99 brightness:0.89 alpha:1]; // Green
    } else if (averageFPS <= 45 && averageFPS > 30) {
        averageFPSColor = [UIColor colorWithHue:(38 / 359.0) saturation:0.99 brightness:0.89 alpha:1];  // Orange
    } else if (averageFPS < 30) {
        averageFPSColor = [UIColor colorWithHue:(6 / 359.0) saturation:0.99 brightness:0.89 alpha:1];   // Red
    }
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:displayString];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:averageFPSColor range:NSMakeRange(0, averageFPSStringLength)];
    
    [self setAttributedText:mutableAttributedString];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideAverageFPSLabel) object:nil];
    [self performSelector:@selector(_hideAverageFPSLabel) withObject:nil afterDelay:1.5];
}

- (void)_hideAverageFPSLabel {
    CATransition *fadeTransition = [CATransition animation];
    
    [self setAttributedText:nil];
    [[self layer] addAnimation:fadeTransition forKey:kCATransition];
    
    [self resetScrollingPerformanceCounters];
}

@end
