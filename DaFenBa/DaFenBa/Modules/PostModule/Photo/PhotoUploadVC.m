//
//  PhotoUploadVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-4.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "PhotoUploadVC.h"
#import "HomeVC.h"
#import "PostProfile.h"
#import "UIImageView+LK.h"


@interface PhotoUploadVC ()<UITextFieldDelegate, UITextViewDelegate>

@end

@implementation PhotoUploadVC


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
    //图片可缩放观看
    self.photoScrollView.maximumZoomScale = 3.0;
    self.photoScrollView.minimumZoomScale = 1.0;
    self.photoScrollView.delegate = self;
    
    
    // MARK:大图
    [self.bigPhotoImageView setImage:[[PostManager shareInstance]postProfile].post];

//    self.photo.onTouchTapBlock =^(UIImageView *imageView)
//    {
//        [self showBigPost:nil];
//    };

    self.bigPhotoImageView.onTouchTapBlock = ^(UIImageView *imageView)
    {
        float size = self.photoScrollView.zoomScale;
        if (size > 1) {
            [self.photoScrollView setZoomScale:1];
        }
        else
            [self hideBigPost];
    };

}


- (void)configSubViews
{
    [self setNavTitle:@"照片信息"];
    self.isNeedBackBTN = YES;
    self.isNeedHideBack = YES;
    
    
    [self.view setBackgroundColor:ThemeBGColor_gray];
    [self.bg1 setImage:areaBgImage];
    [self.bg2 setImage:areaBgImage];
    [self.bg3 setImage:areaBgImage];
    
    [self.bg3 setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchStrech:)];
    [self.bg3 addGestureRecognizer:tap];
    
    
    self.photo.layer.borderColor = [TheMeBorderColor CGColor];
    self.photo.layer.borderWidth = 1;
    self.downView.clipsToBounds  = YES;
    
    self.photo.image               = [[PostManager shareInstance]postProfile].post;
    NSDate *date                   = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat       = @"yyyy-MM-dd";
    NSString *datestr              = [dateFormatter stringFromDate:date];
    self.dateLabel.text            = datestr;
    
//    UINavigationController *nav = (UINavigationController *)APPDELEGATE.mainVC.viewControllers[0];
//    HomeVC *homeVC              = (HomeVC *)nav.viewControllers[0];
    
    NSString *tempStr = STRING_judge(APPDELEGATE.location) ;
    if (tempStr && [tempStr length] > 0) {
        self.locationLabel.text = tempStr;
    }
    else if(APPDELEGATE.latitude != 0)
        self.locationLabel.text = @"未解释您的位置，不影响上传";
    else
        self.locationLabel.text = @"未获取位置，不允许上传";

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.bigPhotoImageView setFrame:self.photo.bounds];
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


#pragma  mark - hide keyboard
- (void)hideKeyBoard
{
    [super hideKeyBoard];
    [UIView beginAnimations:nil context:nil];
    [self resetContSizeOfScrollView];
    // _scrollView.contentOffset = CGPointMake(0, 0);
    [UIView commitAnimations];
 
}


#pragma mark - 展开详情编辑downView

- (void)resetContSizeOfScrollView
{
    if (self.sendBtn.bottom + 20.0 >self.scrollView.bottom) {
        [self.scrollView setContentSize:CGSizeMake(DEVICE_screenWidth, self.sendBtn.bottom +20.0)];
    }
    else
    {
        [self.scrollView setContentSize:CGSizeMake(DEVICE_screenWidth, self.scrollView.height)];
    }

}
- (IBAction)switchStrech:(id)sender
{
    UIViewBeginAnimation(kDuration);
    if (!self.isStreched) {
        self.strechIcon.transform = CGAffineTransformMakeRotation(- M_PI);
        self.isStreched = YES;
        [self.downView setHeight:300.0];
        [self.sendBtn setTop:self.downView.bottom + 20.0];
        
    }
    else
    {
        self.strechIcon.transform = CGAffineTransformIdentity;
        self.isStreched = NO;
        [self.downView setHeight:30.0];
        [self.sendBtn setTop:self.downView.bottom + 20.0];
    }
    [self resetContSizeOfScrollView];
    [UIView commitAnimations];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextField *)textField
{
    [self p_setPlaceholder];
}
- (void)p_setPlaceholder {
    if ([self.photoIntroTextView.text length] != 0) {
        self.placeHolderLabel.text = @"";
    }
    else
        self.placeHolderLabel.text = @"想要说点什么呢～点此输入吧";
}

- (void)textViewDidChange:(UITextView *)textView {
    [self p_setPlaceholder];
    if (self.maxCharacterNum == 0) {
        return;
    }
    NSInteger number = [textView.text length];
    if (number > self.maxCharacterNum) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"字符个数不能大于%d",self.maxCharacterNum] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        textView.text = [textView.text substringToIndex:70];
        number = self.maxCharacterNum;
    }
    // self.statusLabel.text = [NSString stringWithFormat:@"%d/128",number];
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self p_setPlaceholder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self hideKeyBoard];
        return NO;
    }
    
    return YES;
}
#pragma mark -  UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //让整个界面提高 使编辑的textfield不被键盘摭住
    if (textField.superview.bottom + self.downView.top > DEVICE_screenHeight - 64 - 260 ) {

        UIViewBeginAnimation(kDuration);
        _scrollView.contentSize   = CGSizeMake(DEVICE_screenWidth , DEVICE_screenHeight + 260 );
        _scrollView.contentOffset = CGPointMake(0, textField.superview.bottom +  self.downView.top - textField.height - 40);
        [UIView commitAnimations];
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    //[self hideKeyBoard];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        UITextField *txt = (UITextField *)[self.downView viewWithTag:textField.tag +1];
        [txt becomeFirstResponder];
        
    }
    else
    {
        [self hideKeyBoard];
    }
        return YES;
}

#pragma mark - 发送照片
- (IBAction)sendPhoto:(id)sender
{
    [self startAview];

    if (![Coordinator isLogined]) {
        [Coordinator ensureLoginFromVC:self successBlock:^{
            [self sendPhoto:nil];
        } failBlock:^{
            [self stopAview];
        } cancelBlock:^{
            [self stopAview];
        }];
        return;
    }
    
    UserProfile *userProfile = [[MemberManager shareInstance]userProfile];
    if(userProfile == nil) {userProfile = [UserProfile new]; userProfile.userId = @33; [[MemberManager shareInstance]setUserProfile:userProfile];}
    NSString *comment    = self.photoIntroTextView.text;
    NSString *title      = self.titleLabel.text;
    NSString *brand      = self.brandLabel.text;
    NSString *texture    = self.textureLabel.text;
    NSString *highlight  = self.highlightLabel.text;
    NSString *buyUrl     = self.buyUrlLabel.text;
    NSString *buyAddress = self.storeLabel.text;
    PostProfile *postProfie = [[PostManager shareInstance]postProfile];
    postProfie.user      = userProfile;
    postProfie.brand     = brand;
    postProfie.comment   = comment;
    postProfie.title     = title;
    postProfie.texture   = texture;
    postProfie.highlight = highlight;
    postProfie.buyUrl    = buyUrl;
    postProfie.buyAddress = buyAddress;
    

    PostManager *postManager = [PostManager shareInstance];
    postManager.postProfile = postProfie;
    
    [postManager submitPostFromVC:self];
    
}

#pragma mark - 视图跳转
- (void)backToPreVC:(id)sender
{
    [self.uploadDelegate dismissViewControllerAnimated:YES completion:nil];
}

@end
