//
//  SrollLayerView.m
//  SrollLayer
//
//  Created by 胡 帅 on 16/3/9.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import "SrollLayerView.h"
#import <CoreText/CoreText.h>
#import "DataGroup.h"

@implementation SrollLayerView {
    CAScrollLayer *scrollLayer;
    CALayer *contentLayer;
    CAGradientLayer *gradientLayer;
    CAShapeLayer  *gradientMaskLayer, *highLineLayer, *lowLineLayer, *axisLayer, *axisLabelLayer;
    CGPoint panStart, panRealTime, scrollLayerOffset;
    CADisplayLink *displayLink;
    CGFloat pinchRealTime;
    CGPoint pinchCenter;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubLayersWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initSubLayersWithFrame:self.frame];
    }
    return self;
}

- (void) initSubLayersWithFrame:(CGRect) frame {
    self.backgroundColor = [UIColor blueColor];
    scrollLayer = [[CAScrollLayer alloc] init];
    scrollLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    scrollLayer.backgroundColor = [UIColor clearColor].CGColor;
    scrollLayer.scrollMode = kCAScrollHorizontally;
    [self.layer addSublayer:scrollLayer];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    pan.cancelsTouchesInView = NO;
    pan.delaysTouchesBegan = NO;
    pan.delaysTouchesEnded = NO;

    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipe.direction =  UISwipeGestureRecognizerDirectionLeft;
    swipe.cancelsTouchesInView = NO;
    swipe.delaysTouchesBegan = YES;
    swipe.delaysTouchesEnded = YES;
    
    UISwipeGestureRecognizer *swipe2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipe2.direction =  UISwipeGestureRecognizerDirectionRight;
    swipe2.cancelsTouchesInView = NO;
    swipe2.delaysTouchesBegan = YES;
    swipe2.delaysTouchesEnded = YES;


    [pan requireGestureRecognizerToFail:swipe];
    [pan requireGestureRecognizerToFail:swipe2];

    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:swipe];
    [self addGestureRecognizer:swipe2];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    
    [self addGestureRecognizer:pinch];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self panBegan:pan];
            break;
        case UIGestureRecognizerStateChanged:
            [self panChanged:pan];
            break;
        case UIGestureRecognizerStateEnded:
            [self panEnded:pan];
            break;
            
        default:
            break;
    }
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipe {
    switch (swipe.state) {
        case UIGestureRecognizerStateBegan:
            [self swipeBegan:swipe];
            break;
        case UIGestureRecognizerStateChanged:
            [self swipeChanged:swipe];
            break;
        case UIGestureRecognizerStateEnded:
            [self swipeEnded:swipe];
            break;
            
        default:
            break;
    }
}


- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinch {
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan:
            pinchRealTime = 1;
            pinchCenter =  CGPointMake(([pinch locationOfTouch:0 inView:self].x + [pinch locationOfTouch:1 inView:self].x) / 2, ([pinch locationOfTouch:0 inView:self].y + [pinch locationOfTouch:1 inView:self].y) / 2);
            [self.delegate scrollLayerAnchorPointChange2:pinchCenter];

            break;
        case UIGestureRecognizerStateChanged:
            [self pinchChanged:pinch];
            break;
        case UIGestureRecognizerStateEnded:
            break;
            
        default:
            break;
    }
}



- (void)pinchChanged:(UIPinchGestureRecognizer *)pinch {
    if(pinch.numberOfTouches < 2) {
        return;
    }
    
    
    /*   --------  line layer ---------  */
    CGFloat scaleContentLayer = contentLayer.transform.m11;
    scaleContentLayer *= pinch.scale / pinchRealTime;
    
    [CATransaction begin];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGPoint pointInContentLayer = pinchCenter;
    pointInContentLayer.x -= contentLayer.frame.origin.x - scrollLayerOffset.x;
    
    CGRect frame = contentLayer.frame;
    contentLayer.anchorPoint = CGPointMake(pointInContentLayer.x / CGRectGetWidth(contentLayer.frame), 0.5);
    contentLayer.frame = frame;
    
    [CATransaction commit];
    [CATransaction setDisableActions:NO];
    
    contentLayer.transform =  CATransform3DMakeScale( scaleContentLayer, 1, 1);
    
    [CATransaction commit];
    
    
    pinchRealTime = pinch.scale;
}


-(void)panBegan:(UIPanGestureRecognizer*)pan {
    panRealTime = [pan locationInView:self];

}

-(void)panChanged:(UIPanGestureRecognizer*)pan {
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];

    CGPoint current = [pan locationInView:self];
    CGPoint delta = CGPointMake(current.x - panRealTime.x, 0);
    panRealTime = current;
    CGPoint old = scrollLayerOffset;
    scrollLayerOffset.x -= delta.x;

    if (scrollLayerOffset.x > 0 && scrollLayerOffset.x + CGRectGetWidth(self.frame) < CGRectGetWidth(scrollLayer.contentsRect)) {
        [scrollLayer scrollToPoint:scrollLayerOffset];
    } else if (scrollLayerOffset.x < 0 ){
        scrollLayerOffset = CGPointZero;
    } else {
        scrollLayerOffset = old;

    }
}

- (void)panEnded:(UIPanGestureRecognizer*)pan {
    
}


- (void)swipeEnded:(UISwipeGestureRecognizer *)swipe {
    [CATransaction setDisableActions:YES];
    
    CGPoint delta = CGPointMake(swipe.direction == UISwipeGestureRecognizerDirectionLeft ? -CGRectGetWidth(self.frame) : CGRectGetWidth(self.frame), 0);
    
    scrollLayerOffset.x -= delta.x;
    
    if (scrollLayerOffset.x > 0 && scrollLayerOffset.x + CGRectGetWidth(self.frame) < CGRectGetWidth(scrollLayer.contentsRect)) {

    } else if (scrollLayerOffset.x <= 0 ){
        scrollLayerOffset = CGPointZero;
    } else {
        scrollLayerOffset = CGPointMake(CGRectGetWidth(scrollLayer.contentsRect) - CGRectGetWidth(self.frame), 0);
    }
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(swipeDisplay:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)swipeDisplay:(CADisplayLink *) timer {
    BOOL isLeft = scrollLayerOffset.x > scrollLayer.visibleRect.origin.x;
    CGFloat delta = isLeft? 15 : -15;
    if (scrollLayer.visibleRect.origin.x == scrollLayerOffset.x || fabs(scrollLayer.visibleRect.origin.x - scrollLayerOffset.x) < 15) {
        [scrollLayer scrollToPoint:scrollLayerOffset];
        timer.paused = YES;
        [timer invalidate];
    } else {
        CGPoint point = CGPointMake(scrollLayer.visibleRect.origin.x, 0);
        point.x += delta;
        [scrollLayer scrollToPoint:point];
    }
    
}

- (void)swipeBegan:(UISwipeGestureRecognizer *)swipe {
}

- (void)swipeChanged:(UISwipeGestureRecognizer *)swipe {
    }






- (void)setDataSource:(DataGroup *) dataGroup {
    
    dataGroup.dataArray = [dataGroup.dataArray subarrayWithRange:NSMakeRange(0, 200)];
    
    scrollLayer.contentsRect = CGRectMake(0, 0, (dataGroup.dataArray.count - 1) * 10, CGRectGetHeight(self.frame));
    
    if (!contentLayer) {
        contentLayer = [CALayer layer];
        contentLayer.frame = scrollLayer.contentsRect;
        [scrollLayer addSublayer:contentLayer];
    }
    
    if (gradientLayer) {
        [gradientLayer removeFromSuperlayer];
    }
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = contentLayer.bounds;
    gradientLayer.colors = @[(id)[UIColor yellowColor].CGColor, (id)[UIColor clearColor].CGColor];
    gradientLayer.locations = @[@0, @1];
    gradientLayer.opacity = 0;
    
    [contentLayer addSublayer:gradientLayer];

    
    if (highLineLayer) {
        [highLineLayer removeFromSuperlayer];
    }
    highLineLayer = [CAShapeLayer layer];
    highLineLayer.frame = contentLayer.bounds;
    highLineLayer.strokeColor = [UIColor redColor].CGColor;
    highLineLayer.fillColor = [UIColor clearColor].CGColor;
    highLineLayer.strokeEnd = 0;
    [contentLayer addSublayer:highLineLayer];
    
    if (lowLineLayer) {
        [lowLineLayer removeFromSuperlayer];
    }
    lowLineLayer = [CAShapeLayer layer];
    lowLineLayer.frame = contentLayer.bounds;
    lowLineLayer.strokeColor = [UIColor redColor].CGColor;
    lowLineLayer.fillColor = [UIColor clearColor].CGColor;
    lowLineLayer.strokeEnd = 0;
    [contentLayer addSublayer:lowLineLayer];
    

    CGMutablePathRef gradientPath = CGPathCreateMutable();
    CGMutablePathRef highLinePath = CGPathCreateMutable();
    
    __block CGFloat startPointY;
    [dataGroup.dataArray enumerateObjectsUsingBlock:^(DataItem *  obj, NSUInteger idx, BOOL *  stop) {
        CGFloat pointY = CGRectGetHeight(self.frame) -  obj.highValue / dataGroup.maxValue * CGRectGetHeight(self.frame);
        if (idx == 0) {
            startPointY = pointY;
            CGPathMoveToPoint(gradientPath, nil, 0, pointY);
            CGPathMoveToPoint(highLinePath, nil, 0, pointY);
        } else {
            CGPathAddLineToPoint(gradientPath, nil, idx * 10, pointY);
            CGPathAddLineToPoint(highLinePath, nil, idx * 10, pointY);

        }
    }];
    
    CGMutablePathRef lowLinePath = CGPathCreateMutable();
    
    NSEnumerator *enumerator;
    enumerator = [dataGroup.dataArray reverseObjectEnumerator];
    DataItem *obj;
    NSUInteger idx = dataGroup.dataArray.count - 1;
    while (obj = [enumerator nextObject]) {
        CGFloat pointY = CGRectGetHeight(self.frame) -  obj.lowValue / dataGroup.maxValue * CGRectGetHeight(self.frame);
        CGPathAddLineToPoint(gradientPath, nil, idx * 10, pointY);
        idx -= 1;
    }
//    CGPathCloseSubpath(gradientPath);
    CGPathAddLineToPoint(gradientPath, nil, 0, startPointY);


    
    [dataGroup.dataArray enumerateObjectsUsingBlock:^(DataItem *  obj, NSUInteger idx, BOOL *  stop) {
        CGFloat pointY = CGRectGetHeight(self.frame) -  obj.lowValue / dataGroup.maxValue * CGRectGetHeight(self.frame);
        if (idx == 0) {
            CGPathMoveToPoint(lowLinePath, nil, 0, pointY);
        } else {
            CGPathAddLineToPoint(lowLinePath, nil, idx * 10, pointY);
        }
    }];
    
    highLineLayer.path = highLinePath;
    lowLineLayer.path = lowLinePath;
    gradientMaskLayer= [CAShapeLayer layer];
    gradientMaskLayer.frame = contentLayer.bounds;
    gradientMaskLayer.path = gradientPath;
    gradientMaskLayer.fillColor = [UIColor blackColor].CGColor;
    gradientMaskLayer.path = gradientPath;
    
    
   

    [gradientLayer setMask:gradientMaskLayer];

    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    animation.fromValue =  @(scrollLayerOffset.x / scrollLayer.contentsRect.size.width);
    animation.toValue   = @(scrollLayer.frame.size.width / scrollLayer.contentsRect.size.width);
    animation.duration = 2;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    


    [highLineLayer addAnimation:animation forKey:@"appear"];
    [lowLineLayer addAnimation:animation forKey:@"appear"];
    if (axisLayer) {
        [axisLayer removeFromSuperlayer];
    }
    axisLayer = [CAShapeLayer layer];
    
    CGMutablePathRef axisPath = CGPathCreateMutable();
    
    CGFloat cursor = scrollLayerOffset.x + 5;
    while (cursor < CGRectGetWidth(scrollLayer.contentsRect)) {
        CGPathMoveToPoint(axisPath, nil, cursor, 0);
        CGPathAddLineToPoint(axisPath, nil, cursor, CGRectGetHeight(scrollLayer.contentsRect));
        cursor += 5;
        
    }
    
    if (axisLabelLayer) {
        [axisLabelLayer removeFromSuperlayer];
    }
    axisLabelLayer = [CAShapeLayer layer];
    axisLabelLayer.frame =  CGRectMake(0, 0, CGRectGetWidth(scrollLayer.contentsRect), CGRectGetHeight(scrollLayer.contentsRect));
    
     cursor = scrollLayerOffset.x + 20;
    while (cursor < CGRectGetWidth(scrollLayer.contentsRect)) {
        @autoreleasepool {
            CATextLayer *layer = [CATextLayer layer];
            CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)(@"Helvetica"), 0., NULL);
            layer.font = fontRef;
            layer.fontSize = 8.0;
            layer.foregroundColor = [UIColor redColor].CGColor;
            layer.frame = CGRectMake(cursor, self.frame.size.height - 20, 15, 20);
            layer.string = [NSString stringWithFormat:@"%@", @(cursor)];
            [axisLabelLayer addSublayer:layer];
            cursor += 20;
        }
    }
    [scrollLayer addSublayer:axisLabelLayer];
    
    axisLayer.path = axisPath;
    axisLayer.strokeColor = [UIColor yellowColor].CGColor;
//    [scrollLayer addSublayer:axisLayer];
    
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [highLineLayer removeAllAnimations];
    highLineLayer.strokeEnd = 1;
    [lowLineLayer removeAllAnimations];
    lowLineLayer.strokeEnd = 1;
    [gradientMaskLayer removeAllAnimations];
    CABasicAnimation *gradientAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    gradientAnimation.fromValue = @0;
    gradientAnimation.toValue = @1;
    gradientAnimation.duration = 0.3;
    gradientAnimation.fillMode = kCAFillModeForwards;
    gradientAnimation.removedOnCompletion = NO;
    [gradientLayer addAnimation:gradientAnimation forKey:@"appear"];

}



@end
