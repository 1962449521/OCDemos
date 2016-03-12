//
//  MeHomePageVCViewController.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-9.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "MeHomeVC.h"
#import "MeProfileDetailVC.h"

@interface MeHomeVC ()

@end

@implementation MeHomeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = NSStringFromClass([self superclass]);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)AlternativeEditOrFollowSend
{
    self.editBtn.hidden = NO;
    self.sendLetterBtn.hidden = YES;
    self.guangzuBtn.hidden = YES;
}
#pragma mark - dataSource
- (void)assignValueForBasicInfo
{
    UserProfile *userProfile = [Coordinator userProfile];
    if (userProfile.extInfo == nil) {
        userProfile.extInfo = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *extInfo = userProfile.extInfo;
    
    [self.avatarImageView setAvartar:userProfile.avatar ];
    
    
    [self.userNameLabel setText:userProfile.srcName];
    [self.userNameLabel sizeToFit];
    [self.userNameLabel setCenter:CGPointMake(DEVICE_screenWidth/2, self.userNameLabel.center.y)];
    
    //性别
    [self.genderImageView setX:self.userNameLabel.right + 5.0];
    NSNumber *gender = userProfile.gender;
    if ([gender isEqualToNumber:@1]) {
        self.genderImageView.image = [UIImage imageNamed:@"genderBoy"];
    }
    else if ([gender isEqualToNumber:@2]){
        self.genderImageView.image = [UIImage imageNamed:@"genderGirl"];
    }
    else
        self.genderImageView.hidden = YES;
    //简介
    self.introLabel.text = STRING_joint(@"简介：", userProfile.intro);
    
    //关注数
    if(extInfo[@"followCount"]!=nil)
        self.followCountLabel.text = STRING_fromId( extInfo[@"followCount"]);
    if(extInfo[@"followerCount"]!=nil)
        self.fansCountLabel.text =  STRING_fromId( extInfo[@"followerCount"]);
    if (extInfo[@"followCount"]==nil || extInfo[@"followerCount"] == nil) {
        NSDictionary *para =@{@"userId" : userProfile.userId, @"type" : @2, @"lastReqTime" : @0};
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary *receiveObject = [self.netAccess passUrl:FriendModule_count andParaDic:para withMethod:FriendModule_count_method andRequestId:FriendModule_count_tag thenFilterKey:nil useSyn:YES dataForm:7];
            NSDictionary *result = receiveObject[@"result"];
            if (NETACCESS_Success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *countDic = receiveObject[@"counts"];
                    id followCount =  countDic[@"followCount"];
                    id followerCount = countDic[@"followerCount"];
                    UserProfile *userProfile = [Coordinator userProfile];
                    if(userProfile.extInfo == nil) userProfile.extInfo = [NSMutableDictionary dictionary];
                    NSMutableDictionary *extInfo = userProfile.extInfo;
                    if(followCount != nil)[extInfo setValue:followCount forKey:@"followCount"];
                    if(followerCount != nil)[extInfo setValue:followerCount forKey:@"followerCount"];
                    if (self && [self isKindOfClass:[MeHomeVC class]]) {
                        self.followCountLabel.text = STRING_fromId( extInfo[@"followCount"]);
                        self.fansCountLabel.text =  STRING_fromId( extInfo[@"followerCount"]);

                    }
                });
            }
        });
        
    }
    
}

#pragma mark - 视图跳转
- (IBAction)editProfile:(id)sender
{
    MeProfileDetailVC *detailUserVC = [[MeProfileDetailVC alloc]init];
    [self.navigationController pushViewController:detailUserVC animated:YES];
}


@end
