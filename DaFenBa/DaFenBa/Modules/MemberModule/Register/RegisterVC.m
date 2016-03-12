//
//  HSLoginViewController.m
//  SharePhoto
//
//  Created by 胡 帅 on 14-7-22.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "RegisterVC.h"


@interface RegisterVC ()<UITextFieldDelegate>

@end

@implementation RegisterVC

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
    //设置导航栏
    [self setNavTitle:@"注册"];
    self.isNeedBackBTN = YES;
    self.isNeedHideBack = YES;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)configSubViews
{
    //设置输入文本框
    self.user.returnKeyType = UIReturnKeyNext;
    self.user.delegate      = self;
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.delegate = self;
    
    //btn
    [((UIButton *)[self.view viewWithTag:51]) setImage:[UIImage imageNamed:@"radioselected"] forState:UIControlStateSelected];
    [((UIButton *)[self.view viewWithTag:51]) setImage:[UIImage imageNamed:@"radiounselect"] forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:52]) setImage:[UIImage imageNamed:@"radioselected"] forState:UIControlStateSelected];
    [((UIButton *)[self.view viewWithTag:52]) setImage:[UIImage imageNamed:@"radiounselect"] forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:52])setSelected:YES];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 第三方登录

/**
 *	@brief	使用新浪微博登录
 *
 *	@param 	sender 	按钮
 */
- (IBAction)LoginUseSNS:(UIControl *)sender
{
   // [self.loginVC LoginUseSNS:sender];
    [[MemberManager shareInstance]SNSLogin:sender.tag currentVC:self];
    
}
-(IBAction)loginoutWithSina:(id)sender{
    
}

-(IBAction)loginoutWithQQ:(id)sender{
}
#pragma mark -UITextFiledDelegate
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
#pragma mark - 性别选择
- (IBAction)genderSeldected:(id)sender
{
    [((UIButton *)[self.view viewWithTag:51])setSelected:NO];
    [((UIButton *)[self.view viewWithTag:52])setSelected:NO];
    [(UIButton *)sender setSelected:YES];

}
/**
 *	@brief	提交注册并登录
 *
 *	@param 	sender 	<#sender description#>
 */
- (IBAction)registerAndLogin:(id)sender
 {
     NSString *name = self.user.text;
     NSString *password = self.password.text;
     NSNumber *gender = ((UIButton *)[self.view viewWithTag:51]).selected ? @1 : @2;
     if (![MemberManager validateUserInputUserName:name password:password])
     {
         POPUPINFO(@"用户名或密码不符合要求");
         return;
     }
     else
     {
         password = [Coordinator encodePassword:password userName:name];
         UserProfile *baseUserProfile = [[UserProfile alloc]init];
         [baseUserProfile assignValue:@{@"name":name, @"password":password, @"gender":gender}];
         [MemberManager registerUserWithUserProfile:baseUserProfile atVC:self];
     }

 /*
  ** request: {user: {name: user name, password: encoded user password, gender: user gender}}
  */
 
 }
#pragma mark - AsynNetAccessDelegate
//
//- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
//{
//    [self.loginVC receivedObject:receiveObject withRequestId:requestId];
//}
//- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
//{
//    [self.loginVC netAccessFailedAtRequestId:requestId withErro:erroId];
//}

@end
