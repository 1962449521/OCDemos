//
//  AdviceVCFromeOtherVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-16.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "AdviceFromOtherVC.h"
#import "GradeModel.h"
#import "PostProfile.h"
#import "UserProfile.h"
#import "AdviceModel.h"
#import "ScoreSuccessVC.h"
#import "MePhotoDetailVC.h"
#import "HomePageVC.h"
#import "UIImageView+LK.h"

@interface AdviceFromOtherVC ()

@end

@implementation AdviceFromOtherVC
{
    GradeModel *grade;
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
    // Do any additional setup after loading the view.
    if ([self.gradeOrScormanager isKindOfClass:[GradeModel class]]) {
        grade = (GradeModel *)self.gradeOrScormanager;
    }
    
    
    self.p_isSendOut = NO;
    
   
    [self setNavTitle:@"回复建议"];
    self.adviceTitle.text = @"TA的建议";
    
    //禁止显示区的输入
    self.advice.userInteractionEnabled = NO;
    self.placeHolderLabel.hidden = YES;
    self.buyAddress.userInteractionEnabled = NO;
    self.buyUrl.userInteractionEnabled = NO;
    self.buyAddress.placeholder = @"";
    self.buyUrl.placeholder = @"";
    self.sendTextField.hidden = YES;//  屏幕 建议回复功能
    self.sendView.hidden = YES;
    //assignValue for controls------------------------------
    
    if(grade.post.pic)
    {
        [self.postPhoto setPost:grade.post.pic];
        [self.bigPhotoImageView setPost:grade.post.pic];

    }
    if (grade.post.comment && [grade.post.comment length] > 0) {
        [self.photoIntro setText:grade.post.comment];
    }
    if (grade.user.srcName && [grade.user.srcName length] > 0) {
        [self.userName setText:grade.user.srcName];
    }
    if (grade.user.avatar) {
        [self.avatarImageView setAvartar:grade.user.avatar];
        self.avatarImageView.onTouchTapBlock = ^(UIImageView * imageView){
            [HomePageVC enterHomePageOfUser:grade.user fromVC:self];
        };
    }
    if (grade.advice.content && [grade.advice.content length] > 0) {
        [self.advice setText:grade.advice.content];
    }
    if (grade.advice.address && [grade.advice.address length] > 0) {
        [self.buyAddress setText:grade.advice.address];
    }
    if (grade.advice.buyUrl && [grade.advice.buyUrl length] > 0) {
        [self.buyAddress setText:grade.advice.buyUrl];
    }
}
- (void)backToPreVC:(id)sender
{
    NSArray *arr = [self.navigationController viewControllers];
    int top = [arr count]-1;
    if ([arr[top -1] isKindOfClass:[MePhotoDetailVC class]] || [arr[top -1] isKindOfClass:[ScoreSuccessVC class]] ) {
        [arr[top -1] setIsOmittedCheckPostDetail:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
