//
//  ScoreSuccessHeaderVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-11.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ScoreSuccessHeaderVC.h"

#import "ScoreManager.h"
#import "PostProfile.h"
#import "MeHonorVC.h"
#import "GradeModel.h"
#import "UIImageView+LK.h"
#import "HomePageVC.h"



@interface ScoreSuccessHeaderVC ()<pickerUserDelegate>

@end

@implementation ScoreSuccessHeaderVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:ThemeBGColor_gray];
    
    
    //x秒后恭喜获得1分贝消失
    [self p_getDecibel];
    [self assignValueForControls];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 页面跳转
/**
 *	@brief	跳转至我的荣誉页面
 *
 *	@param 	sender 	触发按钮
 */
- (IBAction)p_watchMyDicibel:(id)sender {
    MeHonorVC *vc = [[MeHonorVC alloc]init];
    [[self.userDelegate navigationController] pushViewController:vc animated:YES];
}




/**
 *	@brief	显示分贝获取提示
 */
- (void) p_getDecibel
{
    if(_isOmittedScore)
    {
        [self.scoreFinishView setAlpha:0];

        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fladeTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewBeginAnimation(3);
        [self.scoreFinishView setAlpha:0];
        [UIView commitAnimations];
    });
}



/**
 *	@brief	给控件赋值
 */
- (void) assignValueForControls
{
    ScoreManager *scoreManager = self.scoreManager;
    PostProfile *postProfile = scoreManager.postProfile;
    GradeModel *postGrade = scoreManager.postGrade;
    self.photoImageView.onLoadCompletedBlock = ^(UIImage *image)
    {
        CGSize size = image.size;
        float newHeight = self.photoImageView.width * size.height / size.width;
        if (newHeight < self.photoImageView.height) {//只变小不变大
            CGPoint center = self.photoWrapView.center;
            [self.photoImageView setHeight:newHeight];
            [self.photoWrapView setHeight:newHeight];
            [self.photoWrapView setClipsToBounds:YES];
            [self.photoWrapView setCenter:center];
            [self.showBigPostBtn setFrame:self.photoWrapView.frame];

        }
    };
    [self.photoImageView setPost:postProfile.pic];
    self.scoreCount.text = STRING_fromId( postProfile.gradeCount);
    self.meScoreMatch.text = STRING_fromId( postGrade.matchGrade);
    self.meScoreSize.text = STRING_fromId( postGrade.sizeGrade);
    self.meScoreColor.text = STRING_fromId( postGrade.colorGrade);
    self.meScoreGross.text = STRING_fromId( postGrade.grade);
    if ([postProfile.avgGrade floatValue]>= 10) 
        self.avgScore.text = [NSString stringWithFormat:@"%d", [postProfile.avgGrade intValue]];
    else
        self.avgScore.text = [NSString stringWithFormat:@"%.1f", [postProfile.avgGrade floatValue]];
    
    
    [self.avatarImageView setAvartar:postProfile.user.avatar];
    self.avatarImageView.onTouchTapBlock = ^(UIImageView *imageView){
        [HomePageVC enterHomePageOfUser:postProfile.user fromVC:self.userDelegate];
    };
    self.userNameLabel.text = postProfile.user.srcName;
    self.photoIntroLabel.text = postProfile.comment;
    [self.photoIntroLabel setWidth:232.0];
    [self.photoIntroLabel sizeToFit];
    
    if (self.photoIntroLabel.height > 67.0) {
        [self.titleView setTop:self.photoIntroLabel.bottom + 4.0];
        [self.view setHeight:self.titleView.bottom];
    }
    
    [self.analyze setAlpha:0];
    NSString *analyzeStr = [self.scoreManager postGrade].comment;
    if (![STRING_judge(analyzeStr) isEqualToString:@""]) {
        self.analyze.text = analyzeStr;
    }
}
/**
 *	@brief	分析信息不为空时，予以显示/ 为空时弹出编辑框
 *
 *	@param 	sender 	触发按钮
 */
- (IBAction)popAnalyzeLabel:(id)sender {
    //分析信息不为空
    NSString *txt = [self.scoreManager postGrade].comment;
    if (txt && [txt length] > 0) {
        self.analyze.text = txt;
        UIViewBeginAnimation(kDuration);
        [self.analyze setAlpha:1];
        [UIView commitAnimations];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fladeTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewBeginAnimation(kDuration);
            [self.analyze setAlpha:0];
            [UIView commitAnimations];
            
        });
        
    }
    //分析信息为空
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL sel = NSSelectorFromString(@"popAnalyzeLabel");
        if([self.userDelegate respondsToSelector:sel])
            [self.userDelegate performSelector:sel];
#pragma clang diagnostic pop

        
        
    }
}

@end
