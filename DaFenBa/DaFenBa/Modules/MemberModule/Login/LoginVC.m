//
//  HSLoginViewController.m
//  SharePhoto
//
//  Created by 胡 帅 on 14-7-22.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "LoginVC.h"
#import "RegisterVC.h"
#import "ForgetGetCodeVC.h"

#import <ShareSDK/ShareSDK.h>



@interface LoginVC ()<UITextFieldDelegate>

@property (nonatomic, strong) SNSLoginParam *loginParam;

@end

@implementation LoginVC
{
    NSString *encodePassword;
}

@synthesize loginParam;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //APPDELEGATE.loginVC = self;
        
    }
    return self;
}


- (void)viewDidLoad
{

    [super viewDidLoad];
    //设置导航栏
    [self setNavTitle:@"登录"];
    self.isNeedBackBTN = YES;
    self.isNeedHideBack = YES;
    self.isNeedHideNavBar = YES;
    self.isStatusWhite = YES;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)configSubViews
{
    [super configSubViews];
    //设置输入文本框
    self.user.returnKeyType = UIReturnKeyNext;
    self.user.delegate      = self;
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.delegate = self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 第三方授权
- (IBAction)LoginUseSNS:(UIControl *)sender {
    MemberManager *memberManager = [MemberManager shareInstance];
    [memberManager SNSLogin:sender.tag currentVC:self];
}
#pragma mark - 自行提交用户名和密码登录
-(IBAction) customLogin:(id)sender
{
    NSString *userStr = self.user.text;
    NSString *pwdStr = self.password.text;
    [self.user resignFirstResponder];
    [self.password resignFirstResponder];
    if (![MemberManager validateUserInputUserName:userStr password:pwdStr])
    {
        POPUPINFO(@"用户名或密码不符合要求");
        return;
    }
    encodePassword = [Coordinator encodePassword:pwdStr userName:userStr];

    UserProfile *baseUserProfile = [[UserProfile alloc]init];
    [baseUserProfile assignValue:@{@"name":userStr, @"password":encodePassword}];
    
    [MemberManager loginUserWithUserProfile:baseUserProfile atVC:self];
    
}


#pragma mark - 第三方登录
-(void)realLoginWithParams:(NSDictionary *)params
{
    [self startAview];
    [self.netAccess passUrl:SnsModule_login andParaDic:params withMethod:SnsModule_login_method andRequestId:SnsModule_login_tag thenFilterKey:nil useSyn:NO dataForm:0];
}


#pragma mark - 返回
- (void)backToPreVC:(id)sender
{
    [[MemberManager shareInstance]LoginCancel:nil];
}


#pragma mark - 跳转至注册页面
/**
 *	@brief	Description
 *
 *	@param 	sender 	sender description
 */
- (IBAction)goToRegisterVC:(id)sender
{
    RegisterVC *registerVC = [[RegisterVC alloc]init];
    [self.navigationController pushViewController:registerVC animated:YES];
}
#pragma mark - 跳转至重置密码页面
/**
 *	@brief	Description
 *
 *	@param 	sender 	sender description
 */
- (IBAction)goToForgetVC:(id)sender
{
    ForgetGetCodeVC *forgetVC = [[ForgetGetCodeVC alloc]init];
    //registerVC.loginVC = self;
    [self.navigationController pushViewController:forgetVC animated:YES];
}

#pragma mark -UITextFiledDelegate
/**
 *	@brief	Description
 *
 *	@param 	textField 	textField description
 *
 *	@return	return value description
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.user) {
        [self.password becomeFirstResponder];
    }
    else if(textField == self.password)
    {
        [self hideKeyBoard];
    }
    return YES;
}

#pragma mark - AsynNetAccessDelegate

- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    /*
     customlogin
     response: {result: {success: true, msg: error message}, user: {id: user id, name: user name // generated user name or user inputed name}}
     snslogin
     response: {user: {id: user id, name: user name, password: user password}, result: {success: true, msg: error message}}
     register
     ** response: {result: {success: true, msg: error message}, user: {id: user id, name: user name // generated user name or user inputed name}}
     */
    [super receivedObject:receiveObject withRequestId:requestId];
    NSDictionary *dic;
    if (!TYPE_isDictionary(receiveObject))
    {
        [[MemberManager shareInstance] LoginFail:@"登录失败"];
        return;
    }
    else
    {
        dic = (NSDictionary *)receiveObject;
    }

    NSDictionary *result = dic[@"result"];
    if (NETACCESS_Success) {
        NSDictionary *user = dic[@"user"];
        NSString *userId = user[@"id"];
        NSString *userName = user[@"name"];
        NSString *password = user[@"passsword"];
        if (password == nil) {
            password = encodePassword;
        }
        NSDictionary *userInfo = @{@"userId" : userId, @"userName" : userName, @"password" : password};
        [[MemberManager shareInstance] LoginSuccessful:userInfo];
    }
    else
    {
        [[MemberManager shareInstance] LoginFail:result[@"msg"]];
    }
    
    
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    [super netAccessFailedAtRequestId:requestId withErro:erroId];
    [[MemberManager shareInstance] LoginFail:nil];


    
}
- (IBAction)mockLogin:(id)sender {
    UserProfile *userprofile = [[UserProfile alloc]init];
    userprofile.userId = @22;
    userprofile.name = @"July";
    userprofile.gender = @2;
    userprofile.avatar = @"";
    userprofile.intro = @"I'm a dog";
    userprofile.address = @"广西 桂林";
    userprofile.birthday = @"19991010";
    userprofile.tall = @180;
    userprofile.weight = @62;
    userprofile.email = @"giefee@ww.com";
    userprofile.weixin = @"";
    userprofile.qq = @0;
    userprofile.weibo = @"abcd";
    userprofile.accessToken = @"123456";
    [[MemberManager shareInstance]setUserProfile:userprofile];
    [[MemberManager shareInstance]LoginSuccessful:nil];
}


@end
