//
//  DetaiPhoto.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-5.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ScoreVC.h"
#import "BigFieldVC.h"
#import "GradeModel.h"
#import "AdviceModel.h"
//#import "ScoreSuccessVC.h"
#import "PostProfile.h"
#import "FirstEnterTime.h"
#import "UIImageView+LK.h"
#import "HomePageVC.h"

@interface ScoreVC ()<pickerUserDelegate, UIScrollViewDelegate>

@end

@implementation ScoreVC
{
    BigFieldVC *analyseFild;
    NSString *analyseStr;
    BOOL p_isSubmitBtnClicked;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _value1 = _value2 = _value3 = 6;
        analyseStr = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isNeedHideTabBar = YES;
    [self addGesture];
    [self checkFirstEnter];
    
    //图片可缩放观看
    self.photoScrollView.maximumZoomScale = 3.0;
    self.photoScrollView.minimumZoomScale = 1.0;
    self.photoScrollView.delegate = self;
    
    // MARK: 获取照片详情 A1
    /* 哪种情况是未获知post-detail；1.未登录  2.post没有user
    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //同步方法获取照片详情

        NSDictionary *dic = [self getPostDetailUseSyn:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            [self p_handleNetAccessPostDetailDic:dic];
        });
    });
     */
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 业务逻辑
// get data

// 获取照片详情的时机有两种 A
// 1.首次进入
// 2.首次进入并且未登录，在登录完成后再获取一次

// 判断照片归属的时机 B
// 1.首次进入并且已登录-》获取照片详情-》判断
// 2.首次进入未登录-》获取照片详情-》打分-》点击打分-》登录-》获取详情-》判断

/**
 *	@brief	获取照片详情
 *
 *	@param 	isSyn 	是否用同步
 *
 *	@return	同步时返回结果
 */
- (id)getPostDetailUseSyn:(BOOL)isSyn
{
    PostProfile *postProfile = self.scoreManager.postProfile;
    NSNumber *postId = postProfile.postId;
    
    NSMutableDictionary *para = [@{@"id" : postId} mutableCopy];
    
    NSNumber *userId = [[MemberManager shareInstance]userProfile].userId;
    if(userId == nil)
        userId = @0;
    [para setObject:userId forKey:@"userId"];

    return [self.netAccess passUrl:PostModule_detail andParaDic:para withMethod:PostModule_detail_method andRequestId:PostModule_detail_tag thenFilterKey:nil useSyn:isSyn dataForm:7];

    }
/**
 *	@brief	添加手势识别
 */

- (void)addGesture
{
    self.photoImageView.onTouchTapBlock = ^(UIImageView *imageView)
    {
        [self showBigPost:nil];
    };
    self.bigPhotoImageView.onTouchTapBlock = ^(UIImageView *imageView)
    {
        float size = self.photoScrollView.zoomScale;
        if (size > 1) {
            [self.photoScrollView setZoomScale:1];
        }
        else
            [self hideBigPost];
    };
    /*
    UISwipeGestureRecognizer *swipeLeftGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDetected:)];
    UISwipeGestureRecognizer *swipeRightGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDetected:)];
    swipeLeftGR.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRightGR.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeLeftGR];
    [self.view addGestureRecognizer:swipeRightGR];
  */
}

/**
 *	@brief	检查首次进入页面
 */
- (void)checkFirstEnter
{
    //first enter this page
    FirstEnterTime *first = [FirstEnterTime shareInstance];
    [FirstEnterTime getUserDefault];
    if (first.isFirstEnterScorePage && [first.isFirstEnterScorePage boolValue])
    {
        [APPDELEGATE.mainVC.view addSubview:self.wizardView];
        if(!DEVICE_versionAfter7_0)
        {
            self.wizardView.top = -20;
        }
        
        [self.wizardView setHeight:DEVICE_screenHeight];
        self.wizardView.hidden = NO;
        first.isFirstEnterScorePage = @NO;
        [FirstEnterTime storeUserDeault];
    }
    else
    {
        self.wizardView.hidden = YES;
    }
}

#pragma mark - 视图绘制
- (void)configSubViews
{
    self.isNeedBackBTN = YES;
    [self setNavTitle:@"打分"];
    [self.view setBackgroundColor:ThemeBGColor_gray];
    
    float initValue = 6.0;
    // 三维打分
    _value1 = _value2 = _value3 = initValue;
    // photoScrollView
    
    // slider
    UIImage *stetchLeftTrack= [UIImage imageNamed:@"bar_left"];
    UIImage *stetchRightTrack = [UIImage imageNamed:@"bar_right"];
    [self.slider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    UIImage *thumbImage = [UIImage imageNamed:@"mark.png"];
    [self.slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self.slider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.slider addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventValueChanged];
    [self.slider setValue:initValue animated:YES];
    [self sliderValueChangePure];
    
    // postPhoto
    ScoreManager *scoreManager = self.scoreManager;
    PostProfile *postProfile = [scoreManager postProfile];
    [self.photoImageView setPost:postProfile.pic];
    [self.bigPhotoImageView setPost:postProfile.pic];
    
    // userAvatar userName photoIntro
    [self.avatarImageView setAvartar:postProfile.user.avatar];
    
    self.avatarImageView.onTouchTapBlock = ^(UIImageView *imageView){
        [HomePageVC enterHomePageOfUser:postProfile.user fromVC:self];
    };
    
    self.photoIntro.text = postProfile.comment;
    self.userNameLabel.text = postProfile.user.srcName;
    [self.photoIntro sizeToFit];
    [self.centerView setHeight:MAX(self.photoIntro.bottom, self.userNameLabel.bottom )];
    
    // clothDetail
    [self.clothesDetailView setTop:self.centerView.bottom + 10];
    
    // wrap scrollView
    [self.scrollView setContentSize:CGSizeMake(DEVICE_screenWidth, self.clothesDetailView.bottom + 10)];
}

- (void) refreshDetails
{
    PostProfile *postProfile = self.scoreManager.postProfile;
    self.clothesTitle.text = STRING_judge(postProfile.title);
    self.clothesBrand.text = STRING_judge(postProfile.brand);
    self.clothesTexture.text = STRING_judge(postProfile.texture);
    self.clothesHighLight.text = STRING_judge(postProfile.highlight);
    self.clothesBuyUrl.text = STRING_judge(postProfile.buyUrl);
    self.clothesStorePlace.text = STRING_judge(postProfile.buyAddress);
}
#pragma mark - 用户交互
- (IBAction)pinFenBtnClicked:(UIButton *)sender
{
    int k = sender.tag - 101;
    NSArray *arr = @[NUMBER(_value1), NUMBER(_value2), NUMBER(_value3)];
    [self.scoreManager popOutScoreView:sender withValue: [arr[k] intValue]];
    
    
}

- (IBAction)scoreValueChange:(UIControl *)sender withValue:(NSString *)value
{
    if (sender.tag == 101) {
        _value1 = [value intValue];
    }
    else if(sender.tag == 102){
        _value2 = [value intValue];
    }
    else
        _value3 = [value intValue];
    [self.slider setValue:(_value1 + _value2 +_value3)/3.0 animated:YES];
    
    [self sliderValueChangePure];
}

- (void)sliderValueChange
{
    
    [self sliderValueChangePure];
    
    int oldValue = (int)round((_value1 + _value2 +_value3)/3.0);
    int newValue = (int)round(self.slider.value);
    int delta = newValue - oldValue;//每个按钮平均需加的分数

    if (delta == 0) return;
    int valuelist[3] = {_value1, _value2, _value3};
    int count = 3;
    for (int i = 0; i < count; i++) {
        int oper = delta;
        int j = i;
        while (oper != 0) {
            int old = valuelist[j];
            valuelist[j] += oper;
            if(valuelist[j] < 0) valuelist[j] = 0;
            if(valuelist[j] > 10) valuelist[j] = 10;
            oper -= valuelist[j] - old;
            j = (j+1)%count;
            if(valuelist[0] + valuelist[1] + valuelist[2] == 30 || valuelist[0] + valuelist[1] + valuelist[2] == 0) break;
        }
    }
    _value1 = valuelist[0];
    _value2 = valuelist[1];
    _value3 = valuelist[2];
 
    UIButton *btn1 = (UIButton *)[self.scrollView viewWithTag:101];
    UIButton *btn2 = (UIButton *)[self.scrollView viewWithTag:102];
    UIButton *btn3 = (UIButton *)[self.scrollView viewWithTag:103];
    [btn1 setTitle:STRING_fromInt(_value1) forState:UIControlStateNormal];
    [btn2 setTitle:STRING_fromInt(_value2) forState:UIControlStateNormal];
    [btn3 setTitle:STRING_fromInt(_value3) forState:UIControlStateNormal];

}
- (void)sliderValueChangePure
{
    int value = (int)round(self.slider.value);
    NSString *str2 = STRING_fromInt(value);
    NSString *str = STRING_joint(@"mark", str2);
    UIImage *thumbImage = [UIImage imageNamed:str];
    [self.slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self.slider setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (IBAction)analyse:(id)sender
{
    if(analyseFild == nil)
        analyseFild = [[BigFieldVC alloc]init];
    analyseFild.userDelegate = self;
    analyseFild.isMaskBG = YES;
    analyseFild.titlestr = @"分析";
    analyseFild.value = analyseStr;
    [self.view addSubview:analyseFild.view];
    
    analyseFild.textView.returnKeyType = UIReturnKeyDone;
    [analyseFild show];
    
}
#pragma mark - pickerUserDelegate 弹出输入控件的代理方法实现
- (void)pickerFinishedWithValue:(NSString *)value From:(id)sender
{
    analyseStr = value;
}
- (void)pickerCancelFrom:(id)sender
{
    NSLog(@"2");
}


- (IBAction)submitScore:(id)sender {

    ScoreManager *scoreManager = self.scoreManager;
    if(nil != sender)
        p_isSubmitBtnClicked = YES;
    if ([[MemberManager shareInstance]isLogined] ) {
        // 点击提交按钮，并且已登录，则可知该图片既未打过分，也不是自己发布
        // 若进入界面已登录，则不会进到这里，也获取详情后即判断了
        
        
        //将用户l输入打分项记入内存
        if(scoreManager.postGrade == nil)
            scoreManager.postGrade = [GradeModel new];
        
        GradeModel *curPostGrade = scoreManager.postGrade;
        curPostGrade.grade = NUMBER((int)round(self.slider.value));
        curPostGrade.matchGrade = NUMBER(_value1);
        curPostGrade.sizeGrade = NUMBER(_value2);
        curPostGrade.colorGrade = NUMBER(_value3);
        curPostGrade.comment = analyseStr;
        //提交用入输入的打分值
        [scoreManager submitScore:self];
    }
    else
    {
        
        [self startAview];
        [[MemberManager shareInstance] ensureLoginFromVC:self successBlock:^{
            UserProfile *userProfile = [Coordinator userProfile];
            UserProfile *userPost = self.scoreManager.postProfile.user;
            //判断是否为自己发的照片
            if(userPost != nil && userProfile != nil && [userProfile.name isEqualToString:userPost.name])
            {
                [self stopAview];
                //是自己发的照片
                [ScoreManager evokeScoreWithPostOrScoreManager:self.scoreManager.postProfile FromVC:self];
                return;
            }
            else
            //登录后，如果不是自己发的照片，将获取照片详情做判断是否已打过分
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //同步方法获取照片详情
                NSDictionary *dic = [self getPostDetailUseSyn:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopAview];
                    [self p_handleNetAccessPostDetailDic:dic];
                });
            });
            
        } failBlock:^{
            [self stopAview];
        } cancelBlock:^{
            [self stopAview];
        }];
    }
    
}
#pragma mark - 查看大图
- (IBAction)showBigPost:(id)sender
{
    UIViewBeginAnimation(kDuration);
    [self.photoScrollView setAlpha:1];
    [self.bigPhotoImageView  setWidth:self.view.width];
    [self.bigPhotoImageView  setHeight:self.view.height];
    [self.bigPhotoImageView  setX:0];
    [self.bigPhotoImageView  setY:0];
    
    
    [UIView commitAnimations];
}
- (void)hideBigPost
{
    UIViewBeginAnimation(kDuration);
    [self.photoScrollView setAlpha:0];
    [self.bigPhotoImageView setFrame:self.photoImageView.bounds];
    [UIView commitAnimations];
    
    
    [self.photoScrollView setZoomScale:1];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if(scrollView == self.photoScrollView)
        return self.bigPhotoImageView;
    else
        return nil;
}
#pragma mark - 切换上下页
- (void)swipeDetected:(UISwipeGestureRecognizer *)sender
{
    /* 取消注释实现上下翻页  需改动
    int index = [[ScoreManager shareInstance]indexWithDataSource];
    NSMutableArray *arr = [[GalleryManager shareInstance]selectedDataSource];
    PostProfile *aContentMode;
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {

        if(index == 0)
        {
            POPUPINFO(@"已到达第一页");
            return;
        }
        else
        {
            [[ScoreManager shareInstance]setIsToPre:YES];
            index--;
        }
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (index == [arr count]-1) {
            //load next Page.
            BOOL isLoadSuccess = NO;
            if (!isLoadSuccess) {
                POPUPINFO(@"已到达最后一页");
                return;
            }
        }
        index ++;
    }
    
    aContentMode = arr[index];
    
    UINavigationController *nav = self.navigationController;
    BaseVC *vc = nav.viewControllers[0];
    vc.hidesBottomBarWhenPushed = YES;
    [vc setNavTitle:@"打分"];
    [nav popViewControllerAnimated:NO];//翻页前先将本页出栈
    BaseVC *fromeVC = (BaseVC *)[nav topViewController];
    [[ScoreManager shareInstance]setIndexWithDataSource:index];
    PostProfile *postProfile = [[GalleryManager shareInstance]selectedDataSource][index];
    [[ScoreManager shareInstance] evokeScoreWithPostOrScoreManager:postProfile FromVC:fromeVC];
    vc.hidesBottomBarWhenPushed = NO;
    [vc setNavTitle:@"打分吧"];
*/
}
//隐藏导航层
- (IBAction)hideWizardView:(id)sender {
    self.wizardView.hidden = YES;
}


- (void) p_handleNetAccessPostDetailDic:(NSDictionary *)dic
{
    NSDictionary *result = dic[@"result"];
    if (!NETACCESS_Success)
    {
        POPUPINFO(@"获取照片详情失败");
        return;
    }
    else
    {
        NSDictionary *picDic = dic[@"post"];
        
        ScoreManager *scoreManager = self.scoreManager;
        
        PostProfile *postProfile = scoreManager.postProfile;
        postProfile.gradeCount = picDic[@"gradeCount"];
        postProfile.adviceCount = picDic[@"adviceCount"];
        postProfile.pic = STRING_judge( picDic[@"pic"]);
        postProfile.comment = STRING_judge( picDic[@"comment"]);
        postProfile.avgGrade = picDic[@"avgGrade"];
        postProfile.title = STRING_judge( picDic[@"title"]);
        postProfile.brand = STRING_judge( picDic[@"brand"]);
        postProfile.texture = STRING_judge( picDic[@"texture"]);
        postProfile.highlight = STRING_judge( picDic[@"highlight"]);
        postProfile.buyUrl = STRING_judge( picDic[@"buyUrl"]);
        postProfile.buyAddress = STRING_judge( picDic[@"buyAddress"]);
        
        //post.user
        NSMutableDictionary *postUserM = [dic[@"user"] mutableCopy];
        [postUserM renameKey:@"id" withNewName:@"userId"];
        UserProfile *postUser = [UserProfile new];
        [postUser assignValue:postUserM];
        postProfile.user = postUser;

        
        NSDictionary *postGradeL = dic[@"grade"];
        
        //基于已登录的前提下
        if(postGradeL != nil && [postGradeL count] > 0 )//已打过分
        {
            //赋值 postGrade
            NSMutableDictionary *postGradeM = [postGradeL mutableCopy];
            [postGradeM renameKey:@"id" withNewName:@"gradeId"];
            GradeModel *postGrade = [GradeModel new];
            [postGrade assignValue:postGradeM];
            scoreManager.postGrade = postGrade;
            
            //赋值 postAdvice
        
            NSMutableDictionary *postAdviceM = [dic[@"advice"] mutableCopy];
            [postAdviceM renameKey:@"id" withNewName:@"adviceId"];
            if(postAdviceM != nil)
            {
                AdviceModel *postAdvice = [AdviceModel new];
                [postAdvice assignValue:postAdviceM];
                scoreManager.postAdvice = postAdvice;
            }
            [ScoreManager evokeScoreWithPostOrScoreManager:self.scoreManager FromVC:self];
            
        }
        else
        {
            UserProfile *userProfile = [Coordinator userProfile];
            UserProfile *userPost = self.scoreManager.postProfile.user;
            //判断是否为自己发的照片
            if(userPost != nil && userProfile != nil && [userProfile.userId isEqualToNumber:userPost.userId])
            {
                [self stopAview];
                //是自己发的照片
                [ScoreManager evokeScoreWithPostOrScoreManager:self.scoreManager.postProfile FromVC:self];
                return;
            }
            else
            {
                [self refreshDetails];
                if (p_isSubmitBtnClicked)//该次图片详情请求由提交按钮触发，继续处理未处理完的打分，真实提交
                {
                    p_isSubmitBtnClicked = NO;
                    [self submitScore:nil];
                }
            }
        }
        
    }
}

/*
#pragma mark - AsynNetAccessDelegate

- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    // MARK: 获取照片详情A1
    
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
    
    [self p_handleNetAccessPostDetailDic:dic];
    
}

- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    
    
    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
}*/
@end
