

#import "HSTimer.h"

@implementation HSTimer{
    __weak id _timerDlegate;
}

#pragma mark - 重写NSTimer的实例化方法以规避Retain Cycle

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:( id)userInfo repeats:(BOOL)yesOrNo{
    NSTimer *timer = [[self alloc]  timerWithFireDate:nil interval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    return timer;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo{
    return [[self alloc] timerWithFireDate:nil interval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo{
    NSTimer *timer = [[self alloc]  timerWithFireDate:nil interval:ti target:invocation.target selector:invocation.selector userInfo:nil repeats:yesOrNo];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    return timer;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo{
    return  [[self alloc]  timerWithFireDate:nil interval:ti target:invocation.target selector:invocation.selector userInfo:nil repeats:yesOrNo];
}

- (NSTimer *)timerWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:( id)ui repeats:(BOOL)rep{
    _timerDlegate = t;
    t = nil;
    NSMutableDictionary *parsedUserInfo = [NSMutableDictionary dictionary];
    [parsedUserInfo setValue:ui forKey:@"userInfo"];
    ui = nil;
    
    if (s) {
        [parsedUserInfo setValue:NSStringFromSelector(s) forKey:@"selector"];
        s = nil;
    }
    
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:date interval:ti target:self selector:@selector(p_parsedSelector:) userInfo:parsedUserInfo repeats:rep];
    return timer;
}


- (void) p_parsedSelector:(NSTimer *)timer{
    NSDictionary *parsedUserInfo = [timer userInfo];
    NSString *selectorStr = [parsedUserInfo valueForKey:@"selector"];
    if ([selectorStr isKindOfClass:[NSString class]] && _timerDlegate) {
        id userInfo = [parsedUserInfo valueForKey:@"userInfo"];
        SEL selector = NSSelectorFromString(selectorStr);
        if (selector) {
            [self p_exceuteAction:selector onTarget:_timerDlegate withObject:userInfo];
        }
    }
}

- (void) p_exceuteAction:(SEL)selector onTarget:(id)target withObject:(id)userInfo{
    if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:selector withObject:userInfo];
#pragma clang diagnostic pop
        
    }
}


@end
