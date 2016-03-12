//
//  FriendListCell.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-21.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "FriendListCell.h"
#import "UserProfile.h"

@implementation FriendListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setDataSource:(UserProfile *)user
{
    
    [self.imageView1 setAvartar:user.avatar];
    self.userId = user.userId;
    self.label1.text = user.srcName;
    self.label2.text = user.intro;
    [self setFollowStyle:[user.relationType intValue]];
    
}
- (void)setFollowStyle:(NSUInteger)style
{
    // relationType: 1 // 0: no relationship, 1: follow, 2: follower 3: mutual follow
    NSArray *imageNameStr = @[@"addFollow", @"followed", @"addFollow", @"interFollowed"];
    [self.btn1 setImage:[UIImage imageNamed:imageNameStr[style]] forState:UIControlStateNormal];
}

@end
