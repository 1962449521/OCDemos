//
//  ForgetVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-29.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ForgetGetCodeVC.h"
#import "ForgetValidCodeVC.h"

@interface ForgetGetCodeVC ()

@end

@implementation ForgetGetCodeVC
{
    NSString *mobile;
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
    // Do any additional setup after loading the view from its nib.
    [self setNavTitle:@"重置密码"];
    self.isNeedBackBTN = YES;
    self.isNeedHideBack = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *	@brief	获取验证码
 *
 *	@param 	sender 	<#sender description#>
 */
- (IBAction)getCaptch:(id)sender
 {
     mobile = self.phoneTextField.text;
     if (![self validatePhoneNum:mobile])
         return;
     /*
      ** request: {userId: login user id, mobile: user mobile number} // if not login, userId can be removed
      */
     UserProfile *userProfile = [[MemberManager shareInstance]userProfile];
     NSNumber *userId = userProfile.userId;
          
     NSMutableDictionary *para = [NSMutableDictionary dictionaryWithCapacity:0];
     if(userId)[para setValue:userId forKey:@"userId"];
     if(mobile)[para setValue:mobile forKey:@"mobile"];
     
     // mock data
     NSString *captcha = @"fdfdfdf";
     ForgetValidCodeVC *forgetValidCodeVC = [[ForgetValidCodeVC alloc]initWithParams:@{@"captcha" : captcha, @"mobile" : mobile}];
     [self.navigationController pushViewController:forgetValidCodeVC animated:YES];

     /*
     [self startAview];
     [self.netAccess passUrl:SmsModule_captcha andParaDic:para withMethod:AccessMethodGET andRequestId:SmsModule_captcha_tag thenFilterKey:nil useSyn:NO dataForm:0];*/
 }

- (BOOL) validatePhoneNum:(NSString *)phoneNum
{
    if ([STRING_judge(phoneNum) isEqualToString:@""]) {
        POPUPINFO(@"手机号码不正确");
        return NO;
    }
    return YES;
}
#pragma mark - AsynNetAccessDelegate

- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    [super receivedObject:receiveObject withRequestId:requestId];
    if (!TYPE_isDictionary(receiveObject)) {
        POPUPINFO(@"获取验证码失败");
        return;
    }
    NSDictionary *result = receiveObject[@"result"];
    if (NETACCESS_Success) {
        NSString *captcha = receiveObject[@"captcha"];
        ForgetValidCodeVC *forgetValidCodeVC = [[ForgetValidCodeVC alloc]initWithParams:@{@"captcha" : captcha,  @"mobile" : mobile}];
        [self.navigationController pushViewController:forgetValidCodeVC animated:YES];
    }
    else
    {
        POPUPINFO(@"获取验证码失败");
        return;
    }
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    [super netAccessFailedAtRequestId:requestId withErro:erroId];
}

@end
