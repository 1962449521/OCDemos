//
//  AdviceVCFromMeVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-16.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "AdviceFromMeVC.h"
#import "ScoreManager.h"
#import "PostProfile.h"
#import "AdviceModel.h"
#import "UIImageView+LK.h"
#import "HomePageVC.h"
@interface AdviceFromMeVC ()

@end

@implementation AdviceFromMeVC
{
    ScoreManager *scoreManger;
}

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
    if ([self.gradeOrScormanager isKindOfClass:[ScoreManager class]]) {
        scoreManger = (ScoreManager *)self.gradeOrScormanager;
    }
    
    UserProfile *loginUser = [Coordinator userProfile];
    self.p_isSendOut = (scoreManger.postAdvice == nil || scoreManger.postAdvice.adviceId == nil);
     if (self.p_isSendOut) {
     
         [self.sendTextField setHidden:YES];
         [self setNavTitle:@"给建议"];
         self.adviceTitle.text = @"我的建议";
         
         //开放显示区的输入
         self.advice.userInteractionEnabled = YES;
         self.buyAddress.userInteractionEnabled = YES;
         self.buyUrl.userInteractionEnabled = YES;
         self.placeHolderLabel.text = @"点此输入你的宝贵建议噢...";
     
     }
     
     else //分支2  -》即时聊天输入框显现  -》建议显示区禁止输入
     {
         self.sendView.hidden = YES;  //屏蔽 建议回复

     //分支2.1 当前用户是打分用户
        [self setNavTitle:@"查看建议"];
        self.adviceTitle.text = @"我的建议";

        //禁止显示区的输入
        self.advice.userInteractionEnabled = NO;
        self.placeHolderLabel.hidden = YES;
        self.buyAddress.userInteractionEnabled = NO;
        self.buyUrl.userInteractionEnabled = NO;
         self.buyAddress.placeholder = @"";
         self.buyUrl.placeholder = @"";
     
     }
          //assignValue for controls------------------------------
     
     if(scoreManger.postProfile.pic)
     {
         [self.postPhoto setPost:scoreManger.postProfile.pic];
         [self.bigPhotoImageView setPost:scoreManger.postProfile.pic];
     }
     if (scoreManger.postProfile.comment && [scoreManger.postProfile.comment length] > 0) {
         [self.photoIntro setText:scoreManger.postProfile.comment];
     }
     if (loginUser.srcName && [loginUser.srcName length] > 0) {
         [self.userName setText:loginUser.srcName];
     }
     if (loginUser.avatar) {
         [self.avatarImageView setAvartar:loginUser.avatar];
         self.avatarImageView.onTouchTapBlock = ^(UIImageView *imageView){
             [HomePageVC enterHomePageOfUser:loginUser fromVC:self];
         };
     }
     if (scoreManger.postAdvice.content && [scoreManger.postAdvice.content length] > 0) {
         [self.advice setText:scoreManger.postAdvice.content];
     }
    if (scoreManger.postAdvice.address && [scoreManger.postAdvice.address length] > 0) {
         [self.buyAddress setText:scoreManger.postAdvice.address];
     }
     if (scoreManger.postAdvice.buyUrl && [scoreManger.postAdvice.buyUrl length] > 0) {
         [self.buyAddress setText:scoreManger.postAdvice.buyUrl];
     }
     
     //[self.photoIntro sizeToFit];
     
     
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
