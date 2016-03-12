//
//  ForgetValidCodeVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-4.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ForgetValidCodeVC.h"


@interface ForgetValidCodeVC ()

@end

@implementation ForgetValidCodeVC
{
    int timeCounter;
    NSCondition *gettingCaptchaCondition;
    BOOL isFinishedGetCaptcha;
    
    NSString *encodePassword;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        timeCounter = 60;
        gettingCaptchaCondition = [[NSCondition alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN = YES;
    self.isNeedHideBack = YES;
    [self setNavTitle:@"重置密码"];
    // Do any additional setup after loading the view.
    [self resetSendValideCode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)backToPreVC:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self.navigationController popToViewController:[[MemberManager shareInstance]loginVC] animated:YES];
    
}

#pragma mark - send validCode
- (void)resetSendValideCode
{
    [self.sendBtn setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(renewTime:) userInfo:nil repeats:YES];
    NSString *title = @"重新获取验证码(60s)";
    self.countLabel.text = title;
    self.countLabel.hidden = NO;
    [self.sendBtn setTitle:@"" forState:UIControlStateDisabled];

}
- (IBAction)sendVlideCode:(id)sender
{
    [self resetSendValideCode];
    UserProfile *userProfile = [[MemberManager shareInstance]userProfile];
    NSNumber *userId = userProfile.userId;

    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithCapacity:0];
    [para setValue:userId forKey:@"userId"];
    [para setValue:self.mobile forKey:@"mobile"];
    
    [self startAview];
    [self.netAccess passUrl:SmsModule_captcha andParaDic:para withMethod:AccessMethodGET andRequestId:SmsModule_captcha_tag thenFilterKey:nil useSyn:NO dataForm:0];
}
- (void)renewTime:(NSTimer *)sender
{
    timeCounter--;
    if (timeCounter > 0) {
        NSString *title = [NSString stringWithFormat:@"重新获取验证码(%ds)", timeCounter];
        self.countLabel.text = title;
    }
    else
    {
        if (sender.isValid)
            [sender invalidate];
        timeCounter = 60;
        [self.sendBtn setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        self.countLabel.hidden = YES;
        [self.sendBtn setEnabled:YES];
    }
}
#pragma mark - reset password
- (IBAction)resetPassword:(id)sender
{
    /*
          ** request: {user: {id: login user id, password: encoded user password}, captcha: sms captcha}
     */
    [gettingCaptchaCondition lock];
    while (!isFinishedGetCaptcha) {
        [gettingCaptchaCondition wait];
    }
    [gettingCaptchaCondition unlock];
    if (![self validateInput]) {
        POPUPINFO(@"输入格式有错误");
        return;
    }
    UserProfile *userProfile = [[MemberManager shareInstance]userProfile];
    NSNumber *userId = userProfile.userId;
    NSString *userName = userProfile.name;
    NSString *captcha = self.captcha;
    NSString *password = self.passwordTextField.text;
    encodePassword = [Coordinator encodePassword:password userName:userName];
    
    NSMutableDictionary *user = [NSMutableDictionary dictionaryWithCapacity:0];
    [user setValue:userId forKey:@"id"];
    [user setValue:encodePassword forKey:@"password"];
    NSDictionary *para = @{@"user" : user, @"captcha" : captcha};
    [self.netAccess passUrl:UserModule_resetPwd andParaDic:para withMethod:AccessMethodPUT andRequestId:UserModule_resetPwd_tag thenFilterKey:nil useSyn:NO dataForm:0];
    
    
}
- (BOOL)validateInput
{
//    NSString *mobile = self.mobile;
//    NSString *captcha = self.captcha;
//    NSString *password = self.passwordTextField.text;
    return YES;
}
#pragma mark - AsynNetAccessDelegate

- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    [super receivedObject:receiveObject withRequestId:requestId];
    if (!TYPE_isDictionary(receiveObject)) {
        return;
    }
    NSDictionary *result = receiveObject[@"result"];
    if ([requestId isEqual:SmsModule_captcha_tag]) {
        if (NETACCESS_Success) {
            self.captcha = receiveObject[@"captcha"];
        }
        else
            POPUPINFO(result[@"msg"]);
        [gettingCaptchaCondition lock];
        isFinishedGetCaptcha = YES;
        [gettingCaptchaCondition signal];
        [gettingCaptchaCondition unlock];
        isFinishedGetCaptcha = NO;
    }
    else if([requestId isEqual:UserModule_resetPwd])
    {
        if (NETACCESS_Success) {
            POPUPINFO(@"重置密码成功");
            UserProfile *userProfile = [[MemberManager shareInstance]userProfile];
            userProfile.password = encodePassword;
            
        }
        else
            POPUPINFO(result[@"msg"]);
    }
    
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    [super netAccessFailedAtRequestId:requestId withErro:erroId];
    if ([requestId isEqual:SmsModule_captcha_tag]) {
        [gettingCaptchaCondition lock];
        isFinishedGetCaptcha = YES;
        [gettingCaptchaCondition signal];
        [gettingCaptchaCondition unlock];
        isFinishedGetCaptcha = NO;
    }

}




@end
