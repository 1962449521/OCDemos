//
//  MeVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-24.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "MeVC.h"

#import "FriendVC.h"
#import "SettingHomeVC.h"
#import "MemberManager.h"
#import "MeHomeVC.h"
#import "UserProfile.h"

@interface MeVC ()


@end

@implementation MeVC
{
    NSDictionary *_userHonor;
    NSCondition *condition;
    BOOL countGot;
    BOOL honorGot;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        condition = [[NSCondition alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)configSubViews
{
    //设置导航栏
    [self setNavTitle:@"我"];
    self.isNeedHideTabBar = NO;
    CGRect frame = CGRectMake(0, 12, 20, 20);
    BACK_TITLE(frame, nil, nil, @"addFriend", addFriend);
    frame = CGRectMake(20, 5, 40, 34);
    UIColor *textColor = ColorRGB(244.0, 149.0, 42.0);
    RIGHT_TITLE(frame, @"设置", textColor, nil, Setting);
    //设置背景
    [self.view setBackgroundColor:ThemeBGColor_gray];
    [self.bg1 setImage:areaBgImage];
    [self.bg2 setImage:areaBgImage];
    [self.bg3 setImage:areaBgImage];
    //badge圆角
    self.bageFan.layer.cornerRadius = self.bageFan.width/2;
    

}
/**
 *	@brief	页面赋值
 */
- (void)assignValueForBasicUserInfo
{
    UserProfile *userProfile = [Coordinator userProfile];
    
    [self.avatarImageView setAvartar:userProfile.avatar ];
    self.userNameLabel.text = userProfile.srcName;
    [self.userNameLabel sizeToFit];
    [self.rankButton setX:self.userNameLabel.right + 5.0];
    self.introLabel.text = userProfile.intro;
    [self refreshFollowCounts];
    [self refreshHonorCounts];
}

- (void)viewWillAppear:(BOOL)animated
{
// !!!:更新标志的更新推迟到tab切入时
    [self assignValueForBasicUserInfo];
   if(_isTabChangeIn)
   {
       [self getData];
       _isTabChangeIn = NO;
   }

    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数据获取

- (IBAction)refreshData:(id)sender
{
    NSString *btnTitle = self.rankButton.titleLabel.text;
    if ([btnTitle isEqualToString:@"更新失败，点我重新刷吧"]) {
        [self getData];
    }
    
}
- (void)getData
{
    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [condition lock];
        while (!honorGot || !countGot) {
            [condition wait];
        }
        [condition unlock];
        honorGot = NO;
        countGot = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
        });
    });
    self.followCountLabel.text = @"...";
    self.fansCountLabel.text = @"...";
    self.CommentCountLabel.text = @"...";
    self.photoCountLabel.text = @"...";
    
    
    [self.rankButton setBackgroundImage:[UIImage imageNamed:@"rank0"] forState:UIControlStateNormal];
    [self.rankButton setTitle: @"更新中..." forState:UIControlStateNormal];
    [self.rankButton sizeToFit];
    [self.rankButton setHeight:15];
    NSDictionary *para;

    UserProfile *userProfile = [Coordinator userProfile];
    LastRefreshTime *lrt = [LastRefreshTime shareInstance];
    [LastRefreshTime getUserDefault];
    
    NSNumber *lastReqTime;
    if (lrt.requestTime_FriendCount == nil) {
        lastReqTime = @0;
    }
    else
        lastReqTime = lrt.requestTime_FriendCount;
    para =@{@"userId" : userProfile.userId, @"type" : @2, @"lastReqTime" : lastReqTime};
    [self.netAccess passUrl:FriendModule_count andParaDic:para withMethod:FriendModule_count_method andRequestId:FriendModule_count_tag thenFilterKey:nil useSyn:NO dataForm:7];
    
    para = @{@"userId" : userProfile.userId};
    [self.netAccess passUrl:UserHonorModule_list andParaDic:para withMethod:UserHonorModule_list_method andRequestId:UserHonorModule_list_tag thenFilterKey:nil useSyn:NO dataForm:0];
}


#pragma mark - 视图跳转
- (IBAction)clicked:(UIControl *)sender
{
    NSArray *toControllers = @[@"MeHomeVC", @"nosense", @"nosense", @"MePhotoVC", @"MeCommentVC", @"MeHonorVC"];
    
    if(sender.tag == 1 || sender.tag == 2)
    {
        FriendVC *friendlistVC = [[FriendVC alloc]init];
        friendlistVC.type = sender.tag - 1;
        if (sender.tag == 2) {
            [[[Coordinator userProfile]extInfo]setValue:@0 forKey:@"newFollowerCount"];
        }
        [self.navigationController pushViewController:friendlistVC animated:YES];
        return;
    }
    Class clazz = NSClassFromString(toControllers[sender.tag]);
    BaseVC *vc = (BaseVC *)[[clazz alloc]init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)addFriend
{
    FriendVC *meAddFriendVC = [[FriendVC alloc]init];
    meAddFriendVC.type = FriendListTypeStranger;
    [self.navigationController pushViewController:meAddFriendVC animated:YES];
}

- (void)Setting
{
    SettingHomeVC *settingHomeVC  = [[SettingHomeVC alloc]init];
    [self.navigationController pushViewController:settingHomeVC animated:YES];
    
}

#pragma mark - AsynNetAccessDelegate

- (void)markRefreshFail
{
    [self.rankButton setTitle:@"更新失败，点我重新刷吧" forState:UIControlStateNormal];
    [self.rankButton sizeToFit];
    [self.rankButton setHeight:15];
}
- (void)refreshFollowCounts
{
    UserProfile *userProfile = [Coordinator userProfile];
    
    //关注数
    if (userProfile.extInfo[@"followCount"]) {
        self.followCountLabel.text = [NSString stringWithFormat:@"%@", userProfile.extInfo[@"followCount"]];
        CGPoint center = self.followCountLabel.center;
        [self.followCountLabel sizeToFit];
        self.followCountLabel.center = center;
    }
    
    //粉丝数
    if (userProfile.extInfo[@"followerCount"]) {
        self.fansCountLabel.text = [NSString stringWithFormat:@"%@", userProfile.extInfo[@"followerCount"]];
        CGPoint center = self.fansCountLabel.center;
        [self.fansCountLabel sizeToFit];
        self.fansCountLabel.center = center;
    }
    //新增标志
    if (userProfile.extInfo[@"newFollowerCount"]) {
        [self.bageFan setX:self.fansCountLabel.right + 2];
        if([userProfile.extInfo[@"newFollowerCount"] intValue] > 0 )
            self.bageFan.hidden = NO;
        else {self.bageFan.hidden = YES; }
    }

}
- (void) refreshHonorCounts
{
    NSDictionary *extInfo = [Coordinator userProfile].extInfo;
    if (extInfo[@"gradeCount"])
        self.CommentCountLabel.text = [NSString stringWithFormat:@"（%@）", extInfo[@"gradeCount"]];
    
    if (extInfo[@"postCount"])
        self.photoCountLabel.text = [NSString stringWithFormat:@"（%@）", extInfo[@"postCount"]];
    if (extInfo[@"level"])
    {
        if ( [extInfo[@"level"] intValue] > 0) {
            [self.rankButton setBackgroundImage:[UIImage imageNamed:@"rank1"] forState:UIControlStateNormal];
        }
        else
        {
            [self.rankButton setBackgroundImage:[UIImage imageNamed:@"rank0"] forState:UIControlStateNormal];
        }
        [self.rankButton setTitle: [NSString stringWithFormat:@"LV %@", extInfo[@"level"]] forState:UIControlStateNormal];
        [self.rankButton sizeToFit];
        [self.rankButton setHeight:15];
    }
    
}

- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    if ([requestId isEqualToNumber:FriendModule_count_tag]) {
        [condition lock];
        countGot = YES;
        [condition signal];
        [condition unlock];
    }
    else if([requestId isEqualToNumber:UserHonorModule_list_tag])
    {
        [condition lock];
        honorGot = YES;
        [condition signal];
        [condition unlock];
    }
    NSDictionary *reultDic = (NSDictionary *)receiveObject;

    NSDictionary *result = reultDic[@"result"];
    if (!NETACCESS_Success)
    {
        [super netAccessFailedAtRequestId:requestId withErro:ErrorASI];
        [self markRefreshFail];

        return;
    }
    else
    {
        if ([requestId isEqualToNumber:FriendModule_count_tag])
        {
            NSDictionary *countDic = receiveObject[@"counts"];
            id followCount =  countDic[@"followCount"];
            id followerCount = countDic[@"followerCount"];
            id newFollowerCount = countDic[@"newFollowerCount"];
            UserProfile *userProfile = [Coordinator userProfile];
            LastRefreshTime *lrt = [LastRefreshTime shareInstance];

            
            if(userProfile.extInfo == nil) userProfile.extInfo = [NSMutableDictionary dictionary];
            NSMutableDictionary *extInfo = userProfile.extInfo;
            if(followCount != nil)[extInfo setValue:followCount forKey:@"followCount"];
            if(followerCount != nil)[extInfo setValue:followerCount forKey:@"followerCount"];
            if(newFollowerCount != nil && [lrt.requestTime_FriendCount intValue] != 0)[extInfo setValue:newFollowerCount forKey:@"newFollowerCount"];
            [self refreshFollowCounts];
            
            //更新时间
            lrt.requestTime_FriendCount = receiveObject[@"time"];
            [LastRefreshTime storeUserDeault];
            
        }
        else if ([requestId isEqualToNumber:UserHonorModule_list_tag])
        {
            NSDictionary *userHonor = reultDic[@"userHonor"];
            if(userHonor)
            {
                UserProfile *userProfile = [Coordinator userProfile];
                if(userProfile.extInfo == nil) userProfile.extInfo = [NSMutableDictionary dictionary];
                NSMutableDictionary *extInfo = userProfile.extInfo;
                
                [extInfo setObject:userHonor[@"level"] forKey:@"level"];
                [extInfo setObject:userHonor[@"gradeCount"] forKey:@"totalGradeCount"];
                [extInfo setObject:userHonor[@"postCount"] forKey:@"totalPostCount"];
                [extInfo setObject:userHonor[@"adviceCount"] forKey:@"totalAdviceCount"];
                [extInfo setObject:userHonor[@"totalDb"] forKey:@"totalDb"];
                
                [self refreshHonorCounts];
            }
        }
    }
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    if ([requestId isEqualToNumber:FriendModule_count_tag])
    {
        [condition lock];
        countGot = YES;
        [condition signal];
        [condition unlock];
    }
    else if([requestId isEqualToNumber:UserHonorModule_list_tag])
    {
        [condition lock];
        honorGot = YES;
        [condition signal];
        [condition unlock];
    }

    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
    [self markRefreshFail];
}


@end
