//
//  SecurityPhone.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-2.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

// MARK: 如需测试接口 请设置如下宏

#define isMOCKDATADebugger NO
#define SLEEP //sleep(1.5)

#import "SecurityPhoneVC.h"

@interface SecurityPhoneVC ()<UITextFieldDelegate>

@end

@implementation SecurityPhoneVC
{
    NSUInteger timeCounter;
    NSString *captcha;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        timeCounter = 60;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN = YES;
    self.isNeedHideBack = YES;
    [self setNavTitle:@"绑定手机"];
    self.userNameLabel.text = [Coordinator userProfile].srcName;
    // Do any additional setup after loading the view from its nib.
    
    //draw the bg
    [self.scrollView setBackgroundColor:ThemeBGColor_gray];
    [self.bg1 setImage:areaBgImage];
    [self.bg2 setImage:areaBgImage];
    [self.bg3 setImage:areaBgImage];
    
    [self.sendBtn setTitle:@"(60s)后重发" forState:UIControlStateDisabled];
    [self.sendBtn setBackgroundImage:[UIImage imageNamed: @"bgcc" ]forState:UIControlStateDisabled];
    
    _phoneNumTextField.delegate = self;
    _validCodeTextField.delegate = self;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - send validCode
- (IBAction)sendVlideCode:(id)sender
{
    NSString *phoneNum = STRING_judge(self.phoneNumTextField.text);
    
    if([phoneNum length] == 0)
    {
        POPUPINFO(@"请填写手机号码");
        return;
    }
    
    [self.sendBtn setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(renewTime:) userInfo:nil repeats:YES];
    [self.sendBtn setBackgroundColor:ColorRGB(204.0, 204.0, 204.0)];
    /*
     * captcha: GET
     ** request: {userId: login user id, mobile: user mobile number} // if not login, userId can be removed
     ** response: {captcha: sms captcha, user: {name: user name // for encoding password, id: user id}, result:{success: true, msg: error message}}

     */
    NSNumber *userId = [Coordinator userProfile].userId;
    NSDictionary *para = @{@"userId" : userId, @"mobile" : phoneNum};
    [self startAview];
    if (isMOCKDATADebugger) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SLEEP;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dic = @{@"captcha": @"test", @"user": @{@"name": @"abc", @"id": @13434}, @"result":@{@"success": @YES, @"msg": @""}};
                [self receivedObject:dic withRequestId:SmsModule_captcha_tag];
            });
        });
        
        return;
    }
    [self.netAccess passUrl:SmsModule_captcha andParaDic:para withMethod:SmsModule_captcha_method andRequestId:SmsModule_captcha_tag thenFilterKey:nil useSyn:NO dataForm:7];
    
    
}
- (void)renewTime:(NSTimer *)sender
{
    timeCounter--;
    if (timeCounter > 0) {
        NSString *title = [NSString stringWithFormat:@"(%ds)后重发", timeCounter];
        [self.sendBtn setTitle:title forState:UIControlStateDisabled];
    }
    else
    {
        if (sender.isValid)
            [sender invalidate];
        timeCounter = 60;
        [self.sendBtn setEnabled:YES];
        [self.sendBtn setTitle:@"(60s)后重发" forState:UIControlStateDisabled];
        
    }
}

#pragma mark - 确定
- (IBAction)submit:(id)sender
{
    [self hideKeyBoard];
    NSString *phoneNum =  [self.phoneNumTextField.text stringByReplacingOccurrencesOfString:@"" withString:@""];
    NSString *validCode = [self.validCodeTextField.text stringByReplacingOccurrencesOfString:@"" withString:@""];
    if([STRING_judge(phoneNum) length] == 0 || [STRING_judge(validCode) length] == 0 )
    {
        POPUPINFO(@"请输入手机号码及验证码");
        return;
    }
    if([STRING_judge(captcha) length] == 0 || ![captcha isEqualToString:validCode])
    {
        POPUPINFO(@"请获取并输入正确的验证码");
        return;
    }
//    captcha = @"222";
    /*
     * updateMobile: PUT // need phone verification code
     ** request: {user: {id: login user id, mobile: user mobile}, captcha: sms captcha}
     ** response: {result:{success: true, msg: error message}}
     */
    [self startAview];
    if (isMOCKDATADebugger) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SLEEP;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dic =  @{@"result":@{@"success": @YES, @"msg": @""}};
                [self receivedObject:dic withRequestId:UserModule_updateMobile_tag];
            });
        });
        
        return;
    }
    
    NSNumber *userId = [Coordinator userProfile].userId;
    NSDictionary *para = @{@"user": @{@"id": userId, @"mobile" : phoneNum}, @"captcha" :captcha};
    
    [self.netAccess passUrl:UserModule_updateMobile andParaDic:para withMethod:UserModule_updateMobile_method andRequestId:UserModule_updateMobile_tag thenFilterKey:nil useSyn:NO dataForm:7];
}
#pragma mark -  UITextFieldDelegate
- (void)hideKeyBoard
{
    [super hideKeyBoard];
    [UIView beginAnimations:nil context:nil];
    _scrollView.contentSize = CGSizeMake(DEVICE_screenWidth, 534);
    [_scrollView setContentOffset:CGPointMake(0, 0)];

    [UIView commitAnimations];
    
    
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //让整个界面提高 使编辑的textfield不被键盘摭住
    if (textField.bottom > DEVICE_screenHeight - 64 - 350) {
        float y = textField.bottom - (DEVICE_screenHeight - 64 - 350);
        [UIView beginAnimations:nil context:nil];
        _scrollView.contentSize = CGSizeMake(DEVICE_screenWidth , DEVICE_screenHeight + 350 );
        _scrollView.contentOffset = CGPointMake(0, y);
        [UIView commitAnimations];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyBoard];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return range.location >= 15 ? NO : YES;
    return YES;
}
#pragma mark - AsynNetAccessDelegate


- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    [self stopAview];
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
    if (!NETACCESS_Success)
    {
        if ([requestId isEqualToValue:SmsModule_captcha_tag])
            POPUPINFO(@"验证码获取失败，请重新获取！");
        else if([requestId isEqualToValue:UserModule_updateMobile_tag])
            POPUPINFO(@"手机绑定失败！");

        return;
    }
    else
    {
        if ([requestId isEqualToValue:SmsModule_captcha_tag])
        {
            captcha = receiveObject[@"captcha"];
            POPUPINFO(@"请输入你手机收到的验证码");
        }
        else if([requestId isEqualToValue:UserModule_updateMobile_tag])
        {
            POPUPINFO(@"恭喜你，手机绑定成功");
            self.statusLabel.text = @"已绑定";
        }
    }
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    
    [self stopAview];
    
    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
}




@end
