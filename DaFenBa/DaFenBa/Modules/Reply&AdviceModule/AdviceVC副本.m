//
//  PhotoScoreReplyAdviceVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-12.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "AdviceVC.h"
#import "UserProfile.h"
#import "PostProfile.h"
#import "AdviceModel.h"
#import "GradeModel.h"
#import "ScoreManager.h"

#define maxCharacterNum 120;


@interface AdviceVC ()<UITableViewDelegate, UITableViewDelegate, UITextViewDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@end

@implementation AdviceVC
{
    NSMutableArray *dataSource;
    id currentResponder;
    
    BOOL p_isSendOut;//给出建议
//    GradeModel *_grade;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN    = YES;
    self.isNeedHideBack   = YES;
    self.isNeedHideTabBar = YES;
    [self registerKeyBoardObserve];
    GradeModel *grade = _scoreManager.postGrade;
    
    
    UserProfile *gradeUser  = grade.user;//当from方的意图是由登录用户打分action series而来时，该变量被赋空值
    if(gradeUser == nil)
    {
        gradeUser = [Coordinator userProfile];
    }
    
    //UserProfile *postUser   = _grade.post.user;
    UserProfile *loginUser = [Coordinator userProfile];
    
    //使用何种输入方式
    //分支：1.在显示区直接输入
    //        a. 当前登录用户为打分用户 + 未给过建议 grade.user == loginUser  && grade.advice.comment.length == 0
    //     2.在即时输入框中输入
    //        a. 当前登录用户为打用户 + 已给过建议       b.当前登录用户不是打分的用户
    //
    //是否支持建议修改
    // !!!!!!!!!!!不！！！！！支！！！！！！！！持！！！！！！！！
    
    
    
    //分支1  -》即时聊天输入框隐藏  -》直接在建议显示区输入 给建议
    p_isSendOut = [gradeUser.userId isEqualToNumber: loginUser.userId] && [_scoreManager.postAdvice.content length] == 0;
    if (p_isSendOut) {

        [self.sendTextField setHidden:YES];
        [self setNavTitle:@"给建议"];
        self.adviceTitle.text = @"我的建议";
        
        //开放显示区的输入
        self.advice.userInteractionEnabled = YES;
        self.buyAddress.userInteractionEnabled = YES;
        self.buyUrl.userInteractionEnabled = YES;
        
        self.advice.delegate = self;
        self.buyUrl.delegate = self;
        self.buyAddress.delegate = self;
        
        self.advice.returnKeyType = UIReturnKeyNext;
        self.buyAddress.returnKeyType = UIReturnKeyNext;
        self.buyUrl.returnKeyType = UIReturnKeyDone;
        
        if ([self.advice.text length] != 0)
            self.placeHolderLabel.text = @"";
        else
            self.placeHolderLabel.text = @"点此输入你的宝贵建议噢...";

    }
        
    else //分支2  -》即时聊天输入框显现  -》建议显示区禁止输入
    {
        //分支2.1 当前用户是打分用户
        if ([gradeUser.userId isEqualToNumber: loginUser.userId])
        {
            [self setNavTitle:@"查看建议"];//@"我的建议"];
            self.adviceTitle.text = @"我的建议";
        }
        //分支2.2 当前用户不是打分用户
        else
        {
            if (!(_scoreManager.postAdvice.content && [_scoreManager.postAdvice.content length] > 0)) {
                POPUPINFO(@"TA没提建议啊，你怎么进来的，HACKER？");
                return;
            }

            [self setNavTitle:@"查看建议"];//@"回复建议"];
            self.adviceTitle.text = @"TA的建议";
            
        }
        
        //禁止显示区的输入
        self.advice.userInteractionEnabled = NO;
        self.placeHolderLabel.hidden = YES;
        self.buyAddress.userInteractionEnabled = NO;
        self.buyUrl.userInteractionEnabled = NO;
        
    }
    //图片可缩放观看
    self.photoScrollView.maximumZoomScale = 3.0;
    self.photoScrollView.minimumZoomScale = 1.0;
    self.photoScrollView.delegate = self;
    //assignValue for controls------------------------------
    
    PostProfile *postProfile = _scoreManager.postProfile;
    AdviceModel *advice = _scoreManager.postAdvice;
    if(postProfile.pic)
        [self.postPhoto setPost:postProfile.pic];
    if (postProfile.comment && [postProfile.comment length] > 0) {
        [self.photoIntro setText:postProfile.comment];
    }
    if (postProfile.user.srcName && [postProfile.user.srcName length] > 0) {
        [self.userName setText:postProfile.user.srcName];
    }
    if (postProfile.user.avatar) {
        [self.avatarImageView setAvartar:postProfile.user.avatar];
    }
    if (advice.content && [advice.content length] > 0) {
        [self.advice setText:advice.content];
    }
    if (advice.address && [advice.address length] > 0) {
        [self.buyAddress setText:advice.address];
    }
    if (advice.buyUrl && [advice.buyUrl length] > 0) {
        [self.buyAddress setText:advice.buyUrl];
    }

//[self.photoIntro sizeToFit];
    
    
    
    //-----------------------------=-----------------------
    self.sendTextField.delegate = self;
    self.bigPhotoImageView.image = self.postPhoto.image;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigPost)];
    [self.postPhoto addGestureRecognizer:tap];
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideBigPost)];
    [self.bigPhotoImageView addGestureRecognizer:tap];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 大图预览
- (void)showBigPost
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
    [self.bigPhotoImageView setFrame:self.postPhoto.bounds];
    [UIView commitAnimations];
    
    
    [self.photoScrollView setZoomScale:1];
}
#pragma mark - 键盘事件
- (void)registerKeyBoardObserve
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeContentViewPosition:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeContentViewPosition:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //[self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeKeyBoardObserve
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 根据键盘状态，调整_mainView的位置 只在回复建议时使用
- (void) changeContentViewPosition:(NSNotification *)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        [self.sendView setTop:keyBoardEndY - self.sendView.height - 64];
        
        if (!p_isSendOut) {//上滚以显示最新的聊天记录
            float delta = 64;
            [self.tableView setHeight:keyBoardEndY  - delta];
            [self.tableView setBottom:self.sendView.top];
            CGSize size = self.tableView.contentSize;
            CGRect rect = CGRectMake(5, size.height - 10, 20, 10);
            
            [self.tableView scrollRectToVisible:rect animated:YES];

        }
        }];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return 20;
    if (p_isSendOut) {
        return 0;
    }
    else
        return [dataSource count];
    }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"AdviceMsgCell";
    AllCell *cell = [AllCell cellRegisterNib:cellIdentifier tableView:tableView];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
        currentResponder = textView;
    //if (self.advice.top + self.upperView.bottom + 10> DEVICE_screenHeight - 64 - 260) {
        UIViewBeginAnimation(kDuration);
        [self.downView setTop:-48];
        [self.tableView scrollsToTop];
    
        [UIView commitAnimations];
   // }
    return YES;
}
- (void)hideKeyBoard
{
    [super hideKeyBoard];
    //[self removeKeyBoardObserve];
    UIViewBeginAnimation(kDuration);
    [self.downView setTop:self.upperView.bottom];
    [UIView commitAnimations];

}
//-  (BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
////    UIViewBeginAnimation;
////    [self.downView setTop:self.upperView.bottom];
////    [UIView commitAnimations];
//    [self.buyAddress becomeFirstResponder];
//    return YES;
//}
- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.advice && [textView.text length] != 0)
        self.placeHolderLabel.text = @"";
    else
        self.placeHolderLabel.text = @"点此输入你的宝贵建议噢...";
    
    int maxNum = maxCharacterNum;
    if (maxNum == 0) {
        return;
    }
    NSInteger number = [self.advice.text length];
    if (number > maxNum) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"字符个数不能大于%d",maxNum] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        textView.text = [textView.text substringToIndex:maxNum];
        
    }
    // self.statusLabel.text = [NSString stringWithFormat:@"%d/128",number];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self.buyAddress becomeFirstResponder];
        return NO;
    }
    
    return YES;
    
    
    
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 911)
    {
        [self registerKeyBoardObserve];
    }else
    {
        UIViewBeginAnimation(kDuration);
        [self.downView setTop:-108];
        [self.tableView setContentOffset:CGPointZero];
        [UIView commitAnimations];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    currentResponder = textField;
    if (textField.tag == 911)
        [self removeKeyBoardObserve];
//    else if
//    {
//        UIViewBeginAnimation;
//        [self.downView setTop:self.upperView.bottom];
//        [UIView commitAnimations];
//
//    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 0) {
        [self.buyUrl becomeFirstResponder];
    }
    else if (textField.tag == 1)
        [self hideKeyBoard];
    else if (textField.tag == 999)
        POPUPINFO(@"sendMessage!");
    return YES;
}
#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.bigPhotoImageView;
}
- (IBAction)sendMsg:(id)sender {
    if(p_isSendOut)
        POPUPINFO(@"建议发送在成功");
    else
    {
        NSString *dd = @"dd";
        [dataSource addObject:dd];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[dataSource count]-1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
@end
