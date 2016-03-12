//
//  SMRotaryWheel.m
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.

#import "HPieChartView.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark PieChart


// This determines the distance between the pie chart and the labels,
// or the frame, if no labels are present.
// Examples: if this is 1.0, then they are flush, if it's 0.5, then
// the pie chart only goes halfway from the center point to the nearest
// label or edge of the frame.
#define kRadiusPortion 0.92

#define nFloat(x) [NSNumber numberWithFloat:x]

// Declare private methods.
@interface BNPieChart ()
- (void)initInstance;
- (void)drawSlice;
- (float)pointAtIndex:(int)index;
@end



@implementation BNPieChart
{
    UIImageView *shadowView;
    UIImageView *pin ;
}

@synthesize slicePortions, colors;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initInstance];
        self.frame = frame;    
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initInstance];
    }
    return self;
}



- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    fontSize = frame.size.width / 20;
    if (fontSize < 14) fontSize = 14;
    
    // Compute the center & radius of the circle.
    centerX = frame.size.width/2 ;
    centerY = frame.size.height/2;
    radius = centerX < centerY ? centerX : centerY;
    radius *= kRadiusPortion;
    [self setNeedsDisplay];
}

//绘制区块
- (void)addSlicePortion:(float)slicePortion withName:(NSString *)name {
	[sliceNames addObject:(name ? name : @"")];
    [slicePortions addObject:nFloat(slicePortion)];
	float sumSoFar = [self pointAtIndex:-1];
	[slicePointsIn01 addObject:nFloat(sumSoFar + slicePortion)];
	//[self addLabelForLastName];
}

- (void)drawRect:(CGRect)rect {
	if ([slicePortions count] == 0) {
		//NSLog(@"%s -- called with no slicePortions data", __FUNCTION__);
		return;
	}
    [self drawSlice];
}


#pragma mark private methods

- (void)initInstance {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.slicePortions = [NSMutableArray new];
    slicePointsIn01 = [[NSMutableArray alloc]
                       initWithObjects:nFloat(0.0), nil];
    sliceNames = [NSMutableArray new];
    nameLabels = [NSMutableArray new];
    colorspace = CGColorSpaceCreateDeviceRGB();    
}

- (void)setShadowImage:(NSString *)shadowImage
{
    _shadowImage = shadowImage;
    if (shadowView) {
        [shadowView setImage:[UIImage imageNamed:shadowImage]];
    }
}
- (void)setPinImage:(NSString *)pinImage
{
    _pinImage = pinImage;
    if (pin) {
        [shadowView setImage:[UIImage imageNamed:pinImage]];
    }
}
- (void)setColor:(UIColor *)color
{
    _color = color;
    if (self.valueLabel) {
        self.valueLabel.textColor = color;
    }
}
- (void)drawSlice{

    //指针
    NSString *pinName = @"pin";
    if (self.pinImage) {
        pinName = self.pinImage;
    }
    if (!pin)
        pin = [[UIImageView alloc]initWithFrame:CGRectMake(centerX, centerX, 62, 5.0)];
    [pin setImage:[UIImage imageNamed:pinName]];
    //分划背景
    NSString *imageName = @"shadowBackGround";
    if (self.shadowImage) {
        imageName = self.shadowImage;
    }
    if(!shadowView)
    shadowView = [[UIImageView alloc]initWithFrame:CGRectMake(centerX - 80, centerX - 80, 160, 80)];
    shadowView.alpha = 0.5;
    
    [shadowView setImage:[UIImage imageNamed:imageName]];

    
    [self addSubview:shadowView];
    if (!self.valueLabel)
        self.valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, centerX- 30, 30, 60)];
    if (_color) {
        self.valueLabel.textColor = _color;
    }
    self.valueLabel.backgroundColor = [UIColor clearColor];
    self.valueLabel.text = [NSString stringWithFormat:@"%d", self.value];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.transform = CGAffineTransformRotate(self.valueLabel.transform, M_PI_2);
    [self addSubview:pin];
    [self addSubview:self.valueLabel];
  
}

- (float)pointAtIndex:(int)index {
	index = (index + [slicePointsIn01 count]) % [slicePointsIn01 count];
	return [(NSNumber*)[slicePointsIn01 objectAtIndex:index] floatValue];
}

@end



#pragma mark ------------ Piechart-----------------------

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


static float deltaAngle;
@implementation HPieChartView

@synthesize startTransform, container, cloves, wheelCenter;
@synthesize pie;

- (id) initWithFrame:(CGRect)frame withNum:(int)num withArray:(NSMutableArray *)array startRad:(float)startRad endRad:(float)endRad {
    
    if ((self = [super initWithFrame:frame])) {
        cloves = [[NSMutableArray alloc] initWithCapacity:num];
        self.pie = array;
        self.startRad = startRad;
        self.endRad = endRad;
		[self initWheel];
        
	}
    return self;
}
/**
 *	@brief	初始布局
 */
- (void) initWheel {
    container = [[UIView alloc] initWithFrame:self.frame];
    CGRect frame = self.frame;
    float deltas = 170;
    frame.size.height = deltas;
    frame.size.width  = deltas;
    self.chart = [[BNPieChart alloc] initWithFrame:frame];
    for (int i = 0; i<[pie count]; i++) {
        NSString  * slicePortion = [pie objectAtIndex:i];
        [self.chart addSlicePortion:[slicePortion floatValue] withName:slicePortion];  //
    }
    self.chart.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
    self.chart.layer.position = CGPointMake(container.bounds.size.width/2.0,container.bounds.size.height/2.0);
    [container addSubview:self.chart];
    container.userInteractionEnabled = NO;
    [self addSubview:container];
    [self buildClovesOdd];
    container.transform = CGAffineTransformIdentity;
    CGAffineTransform newTrans = CGAffineTransformRotate(container.transform, self.startRad - M_PI);
    container.transform = newTrans;
}


/**
 *	@brief	建立操作块
 */
- (void) buildClovesOdd {
    
    CGFloat min = 0;
    for (int i = 0; i<[pie count]; i++) {
        NSString  * slicePortion = [pie objectAtIndex:i];
        float fanWidth = M_PI*2*[slicePortion floatValue];
        
        SMClove * clove = [[SMClove alloc] init];
        
        clove.minValue = min;
        clove.midValue = min + fanWidth /2;
        clove.maxValue = min + fanWidth;
        min += fanWidth;
       // NSLog(@"cl is mid=%f min=%f max=%f", clove.midValue,clove.minValue,clove.maxValue);
        [cloves addObject:clove];
    }    
    
}

#pragma mark - 用户交互
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint delta = [touch locationInView:self];
    startTransform = container.transform;
	float dx = delta.x  - container.center.x;
	float dy = delta.y  - container.center.y;
	deltaAngle = atan2(dy,dx);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint pt = [touch locationInView:self];
	
	float dx = pt.x  - container.center.x;
	float dy = pt.y  - container.center.y;
	float ang = atan2(dy,dx);
    
    float angleDif = deltaAngle - ang;
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    CGFloat newVal = 0.0;
    
    
    radians = radians > 0 ? radians : 2*M_PI + radians;
    radians = 2 * M_PI - radians;

    for (SMClove * c in cloves) {
        newVal = c.midValue -radians;
    }
    if (newVal >= self.startRad && newVal <= self.endRad) {
        CGAffineTransform newTrans = CGAffineTransformRotate(startTransform, -angleDif);
        container.transform = newTrans;
        
        CGFloat radians = atan2f(container.transform.b, container.transform.a);
        CGFloat newVal = 0.0;
        
        radians = atan2f(container.transform.b, container.transform.a);
        radians = radians > 0 ? radians : 2*M_PI + radians;
        radians = 2 * M_PI - radians;
        
        for (SMClove * c in cloves) {
            newVal = c.midValue -radians;
            
        }
        float value =  round((newVal - self.startRad) / (self.endRad - self.startRad) * 100);
       // NSLog(@"final score is %f", value);
        if(value <0) value = 0;
        if (value > 100) {
            value = 100;
        }
        self.chart.value =  (int)(round(value/10));
        self.chart.valueLabel.text = [NSString stringWithFormat:@"%d", (int)(round(value/10)) ];
        [self.pinDelegate pinTouchProcessingWithValue:value];
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    
    CGFloat newVal = 0.0;
    radians = radians > 0 ? radians : 2*M_PI + radians;
    radians = 2 * M_PI - radians;
    for (SMClove * c in cloves) {
        newVal = c.midValue -radians;
    }


    if (newVal <self.startRad ) {
        container.transform = CGAffineTransformIdentity;
        CGAffineTransform newTrans = CGAffineTransformRotate(container.transform,self.startRad - M_PI +0.07);
        container.transform = newTrans;
        
    }
    else if (newVal > self.endRad) {
        container.transform = CGAffineTransformIdentity;
        CGAffineTransform newTrans = CGAffineTransformRotate(container.transform, self.endRad - M_PI - 0.07);
        container.transform = newTrans;
        
    }
    radians = atan2f(container.transform.b, container.transform.a);
    
    newVal = 0.0;
    radians = radians > 0 ? radians : 2*M_PI + radians;
    radians = 2 * M_PI - radians;
    for (SMClove * c in cloves) {
        newVal = c.midValue -radians;
        float value =  round((newVal - self.startRad) / (self.endRad - self.startRad) * 100);
        
        if(value <0) value = 0.0;
        if (value > 100.0) {
            value = 100.0;
        }

        self.chart.value =  (int)(round(value/10));
        self.chart.valueLabel.text = [NSString stringWithFormat:@"%d", (int)(round(value/10)) ];

         //NSLog(@"final score is %d", (int)value);
        [self.pinDelegate pinTouchEndWithValue:value];
    }
    
    
}

/**
 *	@brief	设置指针位置
 *
 *	@param 	value 	给定值
 */
- (void) setPinValue:(float)value
{
    float tempt = value;
    if (tempt == 0) tempt = 0.4;
    else if(tempt == 10) tempt = 10 - 0.4;
    float trueValue = tempt *10 * (self.endRad - self.startRad) / 100 +self.startRad;
    container.transform = CGAffineTransformIdentity;
    CGAffineTransform newTrans = CGAffineTransformRotate(container.transform,trueValue - M_PI);
    container.transform = newTrans;
    self.chart.value = (int)value;
    if (self.chart.valueLabel != nil)
        self.chart.valueLabel.text = [NSString stringWithFormat:@"%d", (int)(value)];
  

}


@end
