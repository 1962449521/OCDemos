//
//  BigFieldVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-1.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BigFieldVC.h"

@interface BigFieldVC ()<UITextViewDelegate>

@end

@implementation BigFieldVC
{
    UIView *maskView;
}

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
    [self initHide];
    if (!self.isUseSmallLayout)
        self.textView.delegate = self;

    // Do any additional setup after loading the view from its nib.
    if (![STRING_judge( self.titlestr) isEqualToString:@""]) {
        self.titlelable.text = self.titlestr;
    }
    
//    self.view = self.smallLayout;
//    self.smallTextView.delegate = self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setting
- (void)setTitlestr:(NSString *)titlestr
{
    _titlestr = titlestr;
    if (![STRING_judge( _titlestr) isEqualToString:@""]) {
        if(self.titlelable)
            self.titlelable.text = self.titlestr;
    }

}
- (void)setValue:(NSString *)value
{
    _value = value;
    if (!self.isUseSmallLayout)
        self.textView.text = value;
    else
        self.smallTextField.text =value;
}
- (void)setPlaceHolderStr:(NSString *)str
{
    if (!self.isUseSmallLayout)
    {
    _placeHolderStr = str;
    self.placeHolderLabel.text = str;
    }
    else
    {
        self.smallTextField.placeholder = str;
    }
}

#pragma  mark - 控件使用
- (void)show
{
    
    if (self.isMaskBG) {
        UIView *view = [self.userDelegate view];
        if (maskView == nil)
        {
            maskView = [[UIView alloc]initWithFrame:view.bounds];
            [maskView setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancel:)];
            [maskView addGestureRecognizer:tap];

        }
        [view addSubview:maskView];
        
        
        
        [view bringSubviewToFront:self.view];
        
    }
    if (self.isUseSmallLayout) {
        self.smallLayout.hidden = NO;
        
        
        [self.view setHeight:44.0f];
    }
    [self registerKeyBoardObserve];

    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.view setY:[self.userDelegate view].height - self.view.height ];
 
    [self.view setAlpha:1.0f];
    [self.view.layer addAnimation:animation forKey:@"show"];
    self.view.hidden = NO;
    
  
    
}

- (void)hide
{
    if (maskView != nil && maskView.superview && [self.userDelegate view] == maskView.superview) {
        [maskView removeFromSuperview];
    }
    [self removeKeyBoardObserv];
    [self initHide];
    
    

}
- (void)initHide
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.subtype = kCATransitionFromBottom;
    [self.view setAlpha:0.0f];
    [self.view setY:[self.userDelegate view].height];
    if (self.isUseSmallLayout) {
        [self.smallTextField resignFirstResponder];
    }
    else
    [self.textView resignFirstResponder];
    
    [self.view.layer removeAnimationForKey:@"show"];
    
    [self.view.layer addAnimation:animation forKey:@"hide"];
    

}

- (IBAction)finish:(id)sender
{
    if (sender == nil || ([sender isKindOfClass:[UIButton class]] && ((UIButton *)sender).tag != 100)) {
        self.isNeedGotoNext = YES;
    }

    if (self.isUseSmallLayout) {
        [self.userDelegate pickerFinishedWithValue:self.smallTextField.text From:self];
    }
    else
    [self.userDelegate pickerFinishedWithValue:self.textView.text From:self];
    [self hide];
    
}
- (IBAction)cancel:(id)sender
{
    [self hide];
    
    [self.userDelegate pickerCancelFrom:self];

    
}
#pragma mark - UITextViewDelegate
//- (void)textViewDidBeginEditing:(UITextField *)textField
//{
//    self.placeHolderLabel.text = @"";
//}
- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text length] != 0)
        self.placeHolderLabel.text = @"";
    else
        self.placeHolderLabel.text = self.placeHolderStr;
    if (self.maxCharacterNum == 0) {
        return;
    }
    NSInteger number = [textView.text length];
    if (number > self.maxCharacterNum) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"字符个数不能大于%d",self.maxCharacterNum] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        textView.text = [textView.text substringToIndex:self.maxCharacterNum];
        number = self.maxCharacterNum;
    }
   // self.statusLabel.text = [NSString stringWithFormat:@"%d/128",number];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self finish:nil];
        return NO;
    }

    return YES;
    
    
    
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"frame"]) {
        CGRect frame = [[change valueForKey:NSKeyValueChangeNewKey] CGRectValue];
        float top = frame.origin.y;
        
        if (top < [self.userDelegate view].bottom ) {
            //显示在视图内
            if (self.isUseSmallLayout) {
                [self.smallTextField becomeFirstResponder];
            }
            else
            [self.textView becomeFirstResponder];
        }
    }
}
#pragma mark - 键盘监控
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
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeKeyBoardObserv
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        //当最初执行hide到此处时，会出错，因为当时未加observer. 要么忽视异常，要么判断
        [self.view removeObserver:self forKeyPath:@"frame" context:nil];

    }
    @catch (NSException *exception) {
        ;//do nothing
    }
    @finally {
        ;//let it die
    }
    }

// 根据键盘状态，调整_mainView的位置
- (void) changeContentViewPosition:(NSNotification *)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        float navHeight = 0;
        float statusHeight = 0;
        BaseVC *vc = ((BaseVC *)(self.userDelegate));
        if(vc.navigationController.navigationBar.hidden == NO)
            navHeight = 64;
        if(navHeight == 0 && !DEVICE_versionAfter7_0)statusHeight = 20;
        [self.view setTop:keyBoardEndY - self.view.height - navHeight - statusHeight];
    }];
}


@end
