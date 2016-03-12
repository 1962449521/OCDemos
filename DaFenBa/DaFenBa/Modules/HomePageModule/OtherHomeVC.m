//
//  OtherHomeVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-16.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "OtherHomeVC.h"
#import "BigFieldVC.h"
#import "MemberManager.h"


@interface OtherHomeVC ()<pickerUserDelegate>
{
    BigFieldVC *sendLetterVC;
    BOOL _isFollowed;
    
    NSCondition *condition;
    BOOL isDetailGot;
    BOOL isCountGot;
    BOOL isRelationGot;
    
    
}

@end

@implementation OtherHomeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = NSStringFromClass([self superclass]);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        condition = [NSCondition new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [[MemberManager shareInstance] setUserProfile: nil];
//    [[MemberManager shareInstance] setIsLogined:NO];
//    self.userProfile.relationType = nil;
    
    if (self.userProfile.userId == nil) {
        POPUPINFO(@"用户的id号是空的，怎么找？");
        return;
    }
    [self.sendLetterBtn addTarget:self action:@selector(sendLetter) forControlEvents:UIControlEventTouchUpInside];
    [self.guangzuBtn addTarget:self action:@selector(switchFollow) forControlEvents:UIControlEventTouchUpInside];
    
        [self getData];//获取用户信息，
}
- (void)getData
{
    [self startAview];
    if (self.userProfile.relationType != nil) {//已经知道关系了
        isRelationGot = YES;
        if ([self.userProfile.relationType intValue] == 1 || [self.userProfile.relationType intValue] == 3) {
            _isFollowed = YES;
        }
        else
            _isFollowed = NO;
        [self switchFollowDisplay];
    }
    else//不知道
    {
        UserProfile *loginUser = [Coordinator userProfile];
        if (loginUser == nil) {//未登录
            isRelationGot = YES;
            _isFollowed = NO;
            [self switchFollowDisplay];
        }
    }
    [self getRelationType];
    [self getCountAndDetail];
}
- (void)getRelationType
{
    if(!isRelationGot)
        [self.netAccess passUrl:FriendModule_isFollow andParaDic:@{@"srcId" : [Coordinator userProfile].userId, @"tgtId" : self.userProfile.userId} withMethod:FriendModule_isFollow_method andRequestId:FriendModule_isFollow_tag thenFilterKey:nil useSyn:NO dataForm:7];
}
- (void)getCountAndDetail
{
    UserProfile *userProfile = self.userProfile;
    NSDictionary *para;
    para =@{@"userId" : userProfile.userId };
    if (!isDetailGot)
        [self.netAccess passUrl:UserModule_detail andParaDic:para withMethod:UserModule_detail_method andRequestId:UserModule_detail_tag thenFilterKey:nil useSyn:NO dataForm:7];
    para =@{@"userId" : userProfile.userId, @"type" : @2, @"lastReqTime" :@0};
    if(!isCountGot)
        [self.netAccess passUrl:FriendModule_count andParaDic:para withMethod:FriendModule_count_method andRequestId:FriendModule_count_tag thenFilterKey:nil useSyn:NO dataForm:7];
    
}
- (void)switchFollow1
{

    RelationOperType type;
    if(!_isFollowed)//加关注
        type = RelationOper_follow;
    else
        type = RelationOper_deletefollow;
    [MemberManager changeRelation:type withUser:self.userProfile completedBlock:^(BOOL isSuccess, ChangeRelationResult relation_result) {
//        if (relation_result != Relation_unknown) {
            _isFollowed = (relation_result == Relation_followed);
            [self switchFollowDisplay];
//        }
    } fromVC:self];
    
}

- (void)switchFollow
{
    if (![Coordinator isLogined])
    {
        [self startAview];
        [Coordinator ensureLoginFromVC:self successBlock:^{
            [self stopAview];
            [self switchFollow];
        } failBlock:^{
            [self stopAview];
        } cancelBlock:^{
            [self stopAview];
        }];
        return;
    }
    UserProfile *userProfile = [Coordinator userProfile];

    NSNumber *srcId = userProfile.userId;
    NSString *srcName = userProfile.name;
    
    UserProfile *userProfile2 = self.userProfile;
    NSNumber *tgtId = userProfile2.userId;
    NSString *tgtName = userProfile2.name;
    
    NSDictionary *para;
    [self startAview];

    if(!_isFollowed)//加关注
    {
        para = @{@"follow" : @{@"srcId": srcId, @"srcName" : srcName, @"tgtId" : tgtId, @"tgtName" : tgtName}};
        [self.netAccess passUrl:FriendModule_follow andParaDic:para withMethod:FriendModule_follow_method andRequestId:FriendModule_follow_tag thenFilterKey:nil useSyn:NO dataForm:7];
    }
    else
    {
        para = @{@"follow": @{@"srcId" : srcId, @"tgtId" : tgtId}};
        [self.netAccess passUrl:FriendModule_deleteFollow andParaDic:para withMethod:FriendModule_deleteFollow_method andRequestId:FriendModule_deleteFollow_tag thenFilterKey:nil useSyn:NO dataForm:7];
    }
        
}
- (void)switchFollowDisplay
{
    
    if (_isFollowed) {

        [self.guangzuBtn setTitle:@"关注" forState:UIControlStateNormal];
        [self.guangzuBtn setImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
        [self.guangzuBtn setBackgroundImage:[UIImage imageNamed:@"greeButton"] forState:UIControlStateNormal];
        
    }
    else
    {
        [self.guangzuBtn setTitle:@"加关注" forState:UIControlStateNormal];
        [self.guangzuBtn setImage:nil forState:UIControlStateNormal];
        [self.guangzuBtn setBackgroundImage:[UIImage imageNamed:@"whiteBtn"] forState:UIControlStateNormal];
    }
    UserProfile *userProfile = self.userProfile;
    NSMutableDictionary *extInfo = userProfile.extInfo;
    NSNumber *followerCount = extInfo[@"followerCount"];
    if(followerCount == nil)return;
    //粉丝数
    self.fansCountLabel.text = [NSString stringWithFormat:@"%@", followerCount];
    CGPoint center = self.fansCountLabel.center;
    [self.fansCountLabel sizeToFit];
    self.fansCountLabel.center = center;

}
- (void)sendLetter
{
    if (![Coordinator isLogined]) {
        [self startAview];
        [Coordinator ensureLoginFromVC:self successBlock:^{
            [self stopAview];
            [self sendLetter];
        } failBlock:^{
            [self stopAview];
        } cancelBlock:^{
            [self stopAview];
        }];
        return;
    }
//    if (sendLetterVC == nil) {
//        sendLetterVC = [[BigFieldVC alloc]init];
//        sendLetterVC.userDelegate = self;
//        sendLetterVC.isUseSmallLayout = YES;
//        sendLetterVC.isMaskBG = YES;
//        
//        
//        [self addChildViewController:sendLetterVC];
//        [self.view addSubview:sendLetterVC.view];
//        
//    }
//    sendLetterVC.value = @"";
//    sendLetterVC.placeHolderStr = STRING_joint( @"私信", self.userProfile.srcName);
//    [sendLetterVC show];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)AlternativeEditOrFollowSend
{
    self.editBtn.hidden = YES;
    self.sendLetterBtn.hidden = NO;
    self.guangzuBtn.hidden = NO;
}

- (NSArray *)filterNameArray
{
    return @[@"  @我的", @"  给我的打分", @"  给我的建议", @"  上传照片"];
}
#pragma mark - dataSource

- (void)assignValueForBasicInfo
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [condition lock];
        while (!isDetailGot || !isCountGot || !isRelationGot) {
            [condition wait];
        }
        [condition unlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            UserProfile *userProfile = self.userProfile;
            
            
            NSMutableDictionary *extInfo = userProfile.extInfo;
            
            [self.avatarImageView setAvartar:userProfile.avatar ];
            
            self.userNameLabel.text = userProfile.srcName;
            [self.userNameLabel sizeToFit];
            [self.userNameLabel setCenter:CGPointMake(DEVICE_screenWidth/2, self.userNameLabel.center.y)];
            
            //性别
            [self.genderImageView setX:self.userNameLabel.right + 5.0];
            NSNumber *gender = userProfile.gender;
            if (gender != nil)
            {
                if ([gender isEqualToNumber:@1]) {
                    self.genderImageView.image = [UIImage imageNamed:@"genderBoy"];
                }
                else if ([gender isEqualToNumber:@2]){
                    self.genderImageView.image = [UIImage imageNamed:@"genderGirl"];
                }
                
            }
            //简介
            self.introLabel.text = STRING_joint(@"简介：", STRING_judge(userProfile.intro));
            
            //关注数
            if(extInfo != nil)
            {
                self.followCountLabel.text = STRING_fromId( extInfo[@"followCount"]);
                self.fansCountLabel.text =  STRING_fromId( extInfo[@"followerCount"]);
            }
            [self performSelector:NSSelectorFromString(@"setLayoutThem1")];

        });
    });
    
    
    
    
}

#pragma mark - pickerUserDelegate
- (void)pickerFinishedWithValue:(NSString *)value From:(id)sender
{
    /*
    ** request: {message: {content: message content, srcUserId: source user id, srcName: source user name, tgtUserId: target user id, tgtName: target user name, type: message type}} // type: 1 => post mention, 2 => grade mention, 3 => advice mention, 4 => following user's private message, 5 => un-following user's message, 6 => reply mention
     */
    [self startAview];
    
    UserProfile *userProfile = [Coordinator userProfile];
    NSNumber *srcId = userProfile.userId;
    NSString *srcName = userProfile.name;
    
    UserProfile *userProfile2 = self.userProfile;
    NSNumber *tgtId = userProfile2.userId;
    NSString *tgtName = userProfile2.name;
    
    NSDictionary *para = @{@"message" : @{@"content" : value, @"srcUserId" :srcId, @"srcName" : srcName, @"tgtUserId" : tgtId, @"tgtName" : tgtName, @"type" : @7}};
    
    [self.netAccess passUrl:MessageModule_add andParaDic:para withMethod:MessageModule_add_method andRequestId:MessageModule_add_tag thenFilterKey:nil useSyn:NO dataForm:7];


}
- (void)pickerCancelFrom:(id)sender
{
    [self hideKeyBoard];
}
#pragma mark - AsynNetAccessDelegate
- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    
    if ([requestId isEqualToNumber:UserModule_detail_tag]) {
        [condition lock];
        isDetailGot = YES;
        [condition signal];
        [condition unlock];
    }
    else if([requestId isEqualToNumber:FriendModule_count_tag])
    {
        [condition lock];
        isCountGot = YES;
        [condition signal];
        [condition unlock];
    }
    else if([requestId isEqualToNumber:FriendModule_isFollow_tag])
    {
        [condition lock];
        isRelationGot = YES;
        [condition signal];
        [condition unlock];
    }

    else if([requestId isEqualToNumber:FriendModule_follow_tag] || [requestId isEqualToNumber:FriendModule_deleteFollow_tag] || [requestId isEqualToNumber:MessageModule_add_tag])
        [self stopAview];

    //[super receivedObject:receiveObject withRequestId:requestId];
    NSDictionary *dic;
    if (!TYPE_isDictionary(receiveObject))
    {
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
        return;
    }
    else
    {
        dic = (NSDictionary *)receiveObject;
    }
    
    NSDictionary *result = dic[@"result"];
    if (!NETACCESS_Success && !([requestId isEqualToNumber:FriendModule_isFollow_tag]))
    {
        NSString *str = receiveObject[@"result"][@"msg"];
        NSRange range = [str rangeOfString:@"已经关注"];
        if([requestId isEqualToNumber:FriendModule_follow_tag] && range.length != 0)
        {
            self.userProfile.relationType = @1;
            POPUPINFO(@"之前已经关注过了哦");
            _isFollowed = YES;
            [self switchFollowDisplay];
            return;
        }
        POPUPINFO(@"获取资料失败,"ACCESSFAILEDMESSAGE);
        
        return;
    }
    else
    {
        if ([requestId isEqualToNumber:FriendModule_count_tag])
        {
            /*
             ** response: {counts: {newFollowerCount: new count, followCount: follow count, followerCount: follower count}, result: {success: true, msg: error message}}
             */
            NSDictionary *countDic = receiveObject[@"counts"];
            id followCount =  countDic[@"followCount"];
            id followerCount = countDic[@"followerCount"];
            
            UserProfile *userProfile = self.userProfile;
            if (self.userProfile.extInfo == nil) {
                self.userProfile.extInfo = [NSMutableDictionary dictionary];
            }
            NSMutableDictionary *extInfo = userProfile.extInfo;
            if(extInfo == nil) extInfo = [NSMutableDictionary dictionary];
            if(followCount != nil)[extInfo setValue:followCount forKey:@"followCount"];
            if(followerCount != nil)[extInfo setValue:followerCount forKey:@"followerCount"];
            
            //关注数
            self.followCountLabel.text = [NSString stringWithFormat:@"%@", followCount];
            CGPoint center = self.followCountLabel.center;
            [self.followCountLabel sizeToFit];
            self.followCountLabel.center = center;
            //粉丝数
            self.fansCountLabel.text = [NSString stringWithFormat:@"%@", followerCount];
            center = self.fansCountLabel.center;
            [self.fansCountLabel sizeToFit];
            self.fansCountLabel.center = center;

            
        }
        else if ([requestId isEqualToNumber:UserModule_detail_tag])
        {
            NSDictionary *dic = receiveObject[@"user"];
            [self.userProfile assignValue:dic];
        }
        else if ([requestId isEqualToNumber:FriendModule_isFollow_tag])
        {
            if (receiveObject[@"result"][@"followed"] == nil) {
                _isFollowed = NO;
            }
            else
                _isFollowed = [receiveObject[@"result"][@"followed"] boolValue];
            if(_isFollowed) self.userProfile.relationType = @1;
            else self.userProfile.relationType = @0;
            [self switchFollowDisplay];
        }
        else if([requestId isEqualToNumber:FriendModule_follow_tag])
        {
            if(self.userProfile.extInfo && self.userProfile.extInfo[@"followerCount"] )
            [self.userProfile.extInfo setValue:NUMBER([self.userProfile.extInfo[@"followerCount"] intValue] + 1) forKey:@"followerCount"];
            NSMutableDictionary *extInfo = [Coordinator userProfile].extInfo;
            if (extInfo[@"followCount"])
            {
                int newFollowCount = [extInfo[@"followCount"] intValue];
                [extInfo setValue:NUMBER(newFollowCount + 1) forKey:@"followCount"];
            }
            self.userProfile.relationType = @1;

            POPUPINFO(@"添加关注成功");
            _isFollowed = YES;
            [self switchFollowDisplay];
        }
        else if([requestId isEqualToNumber:FriendModule_deleteFollow_tag])
        {
            if(self.userProfile.extInfo && self.userProfile.extInfo[@"followerCount"] )
            [self.userProfile.extInfo setValue:NUMBER([self.userProfile.extInfo[@"followerCount"] intValue] - 1) forKey:@"followerCount"];
            NSMutableDictionary *extInfo = [Coordinator userProfile].extInfo;
            if (extInfo[@"followCount"])
            {
                int newFollowCount = [extInfo[@"followCount"] intValue];
                [extInfo setValue:NUMBER(newFollowCount - 1) forKey:@"followCount"];
            }
            self.userProfile.relationType = @0;

            POPUPINFO(@"取消关注成功");
            _isFollowed = NO;
            [self switchFollowDisplay];
        }
        else if([requestId isEqualToNumber:MessageModule_add_tag])
        {
            POPUPINFO(@"私信发送成功");
        }


    }
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    if ([requestId isEqualToNumber:UserModule_detail_tag]) {
        [condition lock];
        isDetailGot = YES;
        [condition signal];
        [condition unlock];
    }
    else if([requestId isEqualToNumber:FriendModule_count_tag])
    {
        [condition lock];
        isCountGot = YES;
        [condition signal];
        [condition unlock];
    }
    else if([requestId isEqualToNumber:FriendModule_isFollow_tag])
    {
        self.userProfile.relationType = @0;
        [condition lock];
        isCountGot = YES;
        [condition signal];
        [condition unlock];
    }

     else if([requestId isEqualToNumber:FriendModule_follow_tag] || [requestId isEqualToNumber:FriendModule_deleteFollow_tag] || [requestId isEqualToNumber:MessageModule_add_tag])
        [self stopAview];


    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
}

@end
