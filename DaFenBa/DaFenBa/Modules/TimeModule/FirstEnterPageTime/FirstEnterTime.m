//
//  FirstEnterTime.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "FirstEnterTime.h"

@implementation FirstEnterTime
{
    NSNumber *_isFirstEnterGalleryPage;
    NSNumber *_isFirstEnterScorePage;
    NSNumber *_isFirstEnterScoreSuccessPage;
    NSNumber *_isFirstAppearWatchAddvice;
}
#pragma mark - init
- (id)init
{
    self = [super init];
    if (self) {
        _isFirstEnterScoreSuccessPage = @YES;
        _isFirstEnterGalleryPage = @YES;
        _isFirstEnterScorePage = @YES;
        _isFirstAppearWatchAddvice = @YES;
    }
    return self;
}

+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static FirstEnterTime * instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
    });
    return instance;
}
#pragma mark -  setting/getting
- (void)setIsFirstEnterGalleryPage:(NSNumber *)isFirstEnterGalleryPage
{
    _isFirstEnterGalleryPage = isFirstEnterGalleryPage;
}
- (NSNumber *)isFirstEnterGalleryPage
{
    return _isFirstEnterGalleryPage;
}
- (void)setIsFirstEnterScorePage:(NSNumber *)isFirstEnterScorePage
{
    _isFirstEnterScorePage = isFirstEnterScorePage;
}
- (NSNumber *)isFirstEnterScorePage
{
    return _isFirstEnterScorePage;
}
- (void)setIsFirstEnterScoreSuccessPage:(NSNumber *)isFirstEnterScoreSuccessPage
{
    _isFirstEnterScoreSuccessPage = isFirstEnterScoreSuccessPage;
}
- (NSNumber *)isFirstEnterScoreSuccessPage
{
    return _isFirstEnterScoreSuccessPage;
}
@end
