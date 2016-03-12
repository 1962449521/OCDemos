//
//  AdviceMsgCee.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-17.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "AdviceMsgCell.h"
#import "ReplyModel.h"
#import "UserProfile.h"
#import "DaFenBaDate.h"

@implementation AdviceMsgCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)assignValue:(ReplyModel *)reply
{
    UserProfile *userLogin = [Coordinator userProfile];
    UserProfile *srcUser = reply.srcUser;

    float margin = 10.0;
    if ([userLogin.userId isEqualToNumber:srcUser.userId])
    {//自己发出的消息
        [self.contentBGImageView setImage:[[UIImage imageNamed:@"bubbleGrayFromMe"]stretchableImageWithLeftCapWidth:25 topCapHeight:25]];
        [self.avatarImageView setRight:DEVICE_screenWidth - margin];
    }
    else
    {
        [self.contentBGImageView setImage:[[UIImage imageNamed:@"bubbleGrayFromOther"]stretchableImageWithLeftCapWidth:25 topCapHeight:25]];
        [self.avatarImageView setLeft:margin];

    }
    [self.avatarImageView setAvartar:srcUser.avatar];
    [self.contentLbl setText:reply.content];
    long createTime = [reply.createTime longValue];
    NSString *displayTime = [self dateToMsgStr:createTime];
    [self.sendDateLbl setText:displayTime];
    
    [self.contentLbl setWidth:195.0];
    [self.contentLbl sizeToFit];
    if (self.contentLbl.height > 37) {
        [self.contentBGImageView setHeight:self.contentLbl.height];
        [self.sendDateLbl setTop:self.contentLbl.bottom + 3];
    }
    
    [self.sendDateLbl sizeToFit];
    [self.sendDateLbl setCenter:CGPointMake(DEVICE_screenWidth/2, self.sendDateLbl.center.y)];
    [self.contentView setHeight:self.sendDateLbl.bottom + 2];
    [self setHeight:self.contentView.height ];
    
}
- (NSString *)dateToMsgStr:(long) createTime
{
    return [DaFenBaDate curStr2FromTime:createTime];

}


@end
