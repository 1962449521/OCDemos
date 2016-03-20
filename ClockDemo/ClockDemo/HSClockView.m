//
//  HSClockView.m
//  ClockDemo
//
//  Created by 胡 帅 on 16/3/18.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import "HSClockView.h"
#import "HSTimer.h"

/**
 *  时针、分针、秒针的弧度角（左手二维坐标系下，与X轴正方向的夹角。从屏幕外看，顺时针为增长方向）
 */
typedef struct HSClockHandRadian {
    double hourRadian;
    double minuteRadian;
    double secondRadian;
} HSClockHandRadian;

HSClockHandRadian HSRadianFromTimeInterval(NSTimeInterval time) {
    time += 8 * 60 * 60; //北京时间 +8
    NSInteger offsetIn12Hour = (NSInteger)time % (12 * 60 * 60); // 以12小时为周期时，偏移的秒数，时针
    NSInteger offsetIn1Hour = (NSInteger)time % (1 * 60 * 60); // 以1小时为周期时，偏移的秒数，分针
    NSInteger offsetIn1Minute = (NSInteger)time % (1 * 60); // 以1分钟为周期时，偏移的秒数，秒针
    
    HSClockHandRadian handRaian;
    handRaian.hourRadian = offsetIn12Hour * 1.0 / (12 * 60 * 60) * M_PI * 2- M_PI_2;
    handRaian.minuteRadian = offsetIn1Hour * 1.0  / (1 * 60 * 60) * M_PI * 2 - M_PI_2;
    handRaian.secondRadian = offsetIn1Minute * 1.0  / (1 * 60) * M_PI * 2 - M_PI_2;
    return handRaian;
}

HSClockHandRadian HSTimeFromTimeStr(NSString *timeStr) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString *dateStr = [NSString stringWithFormat:@"1970-01-01 %@", timeStr];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    NSTimeInterval timeStamp = [date timeIntervalSince1970];
    return HSRadianFromTimeInterval(timeStamp);
}

HSClockHandRadian HSTimeFromDate(NSDate *date) {
    NSTimeInterval timeStamp = [date timeIntervalSince1970];
    return HSRadianFromTimeInterval(timeStamp);
}



@interface HSClockView()

/**
 *  内部标识时钟是否在运行中
 */
@property (nonatomic, assign, getter=isWorking) BOOL working;

/**
 *  初始化当前时间，背景，指针, 供代码创建与xib创建共用
 */
- (void) p_initClockView;

/**
 *  初始化指针并返回
 *
 *  @param width      指针宽度
 *  @param height     指针高度
 *  @param tailLength 指针尾部长度
 *  @param tickLength 指针尖部长度
 *
 *  @return 初始化好path的ShapeLayer
 */
- (CAShapeLayer *) p_handLayerWithWidth:(CGFloat)width height:(CGFloat)height tailLength:(CGFloat)tailLength tickLength:(CGFloat)tickLength;

/**
 *  不含时钟运行标识判断与修改的私有方法，动画执行与UI更新主方法
 *
 *  @param time 要设置的时间戳
 */
- (void) p_setTime:(NSTimeInterval)time;

/**
 *  定时器的触发处理，更新钟表时间
 */
- (void) p_handleTimeSource;

@end

@implementation HSClockView {
    CAShapeLayer *_hourLayer;
    CAShapeLayer *_minuteLayer;
    CAShapeLayer *_secondLayer;
    NSTimer *_timer;
}

#pragma mark -  lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self p_initClockView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self p_initClockView];
    }
    return self;
}

- (void) p_initClockView {
    CGRect dialRect = self.bounds;
    
    // 绘制时针
    CGFloat layerWidth = CGRectGetWidth(dialRect) / 3.5;
    CGFloat layerHeight = CGRectGetHeight(dialRect) / 24;
    _hourLayer = [self p_handLayerWithWidth:layerWidth height:layerHeight tailLength:0 tickLength:layerHeight / 1.2];
    [self.layer addSublayer:_hourLayer];
    
    // 绘制分针
    layerWidth = CGRectGetWidth(dialRect) / 3.5 * 1.4;
    layerHeight = CGRectGetHeight(dialRect) / 48;
    _minuteLayer = [self p_handLayerWithWidth:layerWidth height:layerHeight tailLength:5.0 tickLength: layerHeight * 2];
    [self.layer addSublayer:_minuteLayer];
    
    // 绘制分针
    layerWidth = CGRectGetWidth(dialRect) / 3.5 * 1.2 * 1.5;
    layerHeight = CGRectGetHeight(dialRect) / 48 / 2;
    _secondLayer = [self p_handLayerWithWidth:layerWidth * 0.1 height:layerHeight tailLength:20 tickLength: layerWidth * 0.8];
    [self.layer addSublayer:_secondLayer];

    // 绘制中心盖帽
    CAGradientLayer *cap = [CAGradientLayer layer];
    cap.frame = self.bounds;
    cap.colors = @[( id)[UIColor blackColor].CGColor, ( id)[UIColor lightGrayColor].CGColor];
    cap.locations = @[@0.47, @0.53];
    
    CAShapeLayer *capMask = [CAShapeLayer layer];
    capMask.frame = self.bounds;
    CGFloat radius = 10.0;
    CGRect rect = CGRectMake(CGRectGetWidth(dialRect) / 2 - radius, CGRectGetHeight(dialRect) / 2 - radius, radius * 2, radius * 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    capMask.path = path.CGPath;

    cap.mask = capMask;
    [self.layer addSublayer:cap];
        
}

- (CAShapeLayer *) p_handLayerWithWidth:(CGFloat)width height:(CGFloat)height tailLength:(CGFloat)tailLength tickLength:(CGFloat)tickLength {
    CGRect dialRect = self.bounds;
    CGPoint dialCenter = CGPointMake(CGRectGetWidth(dialRect) / 2.0, CGRectGetHeight(dialRect) / 2.0);
    
    CGFloat layerWidth = width;
    CGFloat layerHeight = height;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    CGPoint addingPoint, controlPoint1, controlPoint2;
    addingPoint = CGPointMake(dialCenter.x - tailLength, dialCenter.y  - layerHeight / 2.0); // 左上顶点
    [bezierPath moveToPoint:addingPoint];
    addingPoint = CGPointMake(dialCenter.x - tailLength, dialCenter.y  + layerHeight / 2.0); // 左下顶点
    controlPoint1 = CGPointMake(dialCenter.x  - layerHeight * 3.0 / 4.0 - tailLength,dialCenter.y  - layerHeight / 2.0); // 最左端圆弧控制点 1
    controlPoint2 = CGPointMake(dialCenter.x  - layerHeight * 3.0 / 4.0 - tailLength,dialCenter.y  + layerHeight / 2.0); // 最左端圆弧控制点 2
    
    
    [bezierPath addCurveToPoint:addingPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    addingPoint = CGPointMake(dialCenter.x + layerWidth, dialCenter.y + layerHeight / 2.0); // 右下顶点
    [bezierPath addLineToPoint:addingPoint];
    addingPoint =  CGPointMake(dialCenter.x + layerWidth + tickLength,dialCenter.y); // 最右端尖点
    [bezierPath addLineToPoint:addingPoint];
    addingPoint = CGPointMake(dialCenter.x + layerWidth, dialCenter.y - layerHeight / 2.0); // 右上顶点
    [bezierPath addLineToPoint:addingPoint];
    
    [bezierPath closePath];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.frame = self.bounds;
    
    shapeLayer.fillColor = [UIColor blackColor].CGColor;
    shapeLayer.strokeColor = [UIColor grayColor].CGColor;
    
    return shapeLayer;
}

- (void)dealloc {
    [_timer invalidate];
    NSLog(@"clock view dealloced");

}

#pragma mark - 设置图片或数值并显示

- (void) setDialBackgroundImage:(UIImage *) image {
    CGImageRef imageRef = image.CGImage;
    self.layer.contents = (__bridge id )(imageRef);
    self.layer.contentsScale = [UIScreen mainScreen].scale;
}

- (void) setTime:(NSTimeInterval)time {
    if (self.isWorking) {
        [self pause];
    }
    [self p_setTime:time];
    [self work];
}

- (void) work {
    if(!self.isWorking) {
        [_timer invalidate];
        _timer = [HSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(p_handleTimeSource) userInfo:nil repeats:YES];
        self.working = YES;
    }
}

- (void) pause {
    if([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    self.working = NO;
}


#pragma mark 私有方法

- (void) p_handleTimeSource {
    [self willChangeValueForKey:@"time"];
    [self p_setTime:self.time];
    [self didChangeValueForKey:@"time"];
    _time += 1;
}

- (void) p_setTime:(NSTimeInterval)time {
    _time = time;
    HSClockHandRadian radians = HSRadianFromTimeInterval(time);
    
    CATransform3D transformHour, transformMinute, transformSecond;
    transformHour = transformMinute = transformSecond = CATransform3DIdentity;
    
    transformHour.m11 = cos(radians.hourRadian);
    transformHour.m12 = sin(radians.hourRadian);
    transformHour.m21 = -sin(radians.hourRadian);
    transformHour.m22 = cos(radians.hourRadian);
    
    transformMinute.m11 = cos(radians.minuteRadian);
    transformMinute.m12 = sin(radians.minuteRadian);
    transformMinute.m21 = -sin(radians.minuteRadian);
    transformMinute.m22 = cos(radians.minuteRadian);
    
    transformSecond.m11 = cos(radians.secondRadian);
    transformSecond.m12 = sin(radians.secondRadian);
    transformSecond.m21 = -sin(radians.secondRadian);
    transformSecond.m22 = cos(radians.secondRadian);
    
    [CATransaction begin];
    _hourLayer.transform = transformHour;
    _minuteLayer.transform = transformMinute;
    _secondLayer.transform = transformSecond;
    
    [CATransaction commit];
}

#pragma mark - KVO支持
+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"time"]) {
        return NO;
    } else {
        return [super automaticallyNotifiesObserversForKey:key];
    }
}


@end
