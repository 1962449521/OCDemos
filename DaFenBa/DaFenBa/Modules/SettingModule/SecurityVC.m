//
//  SecurityVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-2.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

// MARK: 如需测试接口 请设置如下宏

#define isMOCKDATADebugger NO
#define SLEEP 


#import "SecurityVC.h"
#import "MCProgressBarView.h"
#import "SecurityPhoneVC.h"

@interface SecurityVC ()

@end

@implementation SecurityVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)drawProgressView
{
    //draw the progressView
    CGRect rect = CGRectMake(12, 63, DEVICE_screenWidth - 24, 20);
    UIImage * backgroundImage = [[UIImage imageNamed:@"progress-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage * foregroundImage = [[UIImage imageNamed:@"progress-fg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    MCProgressBarView * progressBarView = [[MCProgressBarView alloc] initWithFrame:rect
                                                                   backgroundImage:backgroundImage
                                                                   foregroundImage:foregroundImage];
    [self.scrollView addSubview:progressBarView];
    [progressBarView setProgress:0.9];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN = YES;
    [self setNavTitle:@"帐号安全"];
    // Do any additional setup after loading the view from its nib.
    
    //[self drawProgressView];
    //draw the bg
    [self.scrollView setBackgroundColor:ThemeBGColor_gray];
    [self.bg2 setImage:areaBgImage];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [self getData];
    [super viewDidAppear:animated];
}
- (void)getData
{
    /*
    * loadMobile: GET
    ** request: {userId: login user id}
    ** response: {result:{success: true, msg: error message}, mobile: user mobile} // if mobile is empty, it means mobile is unbound
     */
    [self startAview];
    if(isMOCKDATADebugger)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SLEEP;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dic = @{@"result":@{@"success": @YES, @"msg": @""}, @"mobile": @""};
                [self receivedObject:dic withRequestId:UserModule_loadMobile_tag];
            });
        });
        return;
    }
    NSNumber *userId = [Coordinator userProfile].userId;
    [self.netAccess passUrl:UserModule_loadMobile andParaDic:@{@"userId" : userId} withMethod:UserModule_loadMobile_method andRequestId:UserModule_loadMobile_tag thenFilterKey:nil useSyn:NO dataForm:7];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)bindPhone:(id)sender
{
    SecurityPhoneVC *securityPhoneVC = [[SecurityPhoneVC alloc]init];
    [self.navigationController pushViewController:securityPhoneVC animated:YES];
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
        POPUPINFO(@"信息获取失败");
        return;
    }
    else
    {
        NSString *mobileStr = STRING_judge( receiveObject[@"mobile"]);
        if([mobileStr length] != 0)
        {
            self.boundPhoneNumLabel.text = mobileStr;
            self.boundImageView.hidden = NO;
            self.bindBtn.hidden = YES;
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
