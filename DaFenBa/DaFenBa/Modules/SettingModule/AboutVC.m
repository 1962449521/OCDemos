//
//  AboutVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-2.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "AboutVC.h"
#import <StoreKit/StoreKit.h>
#import "Harpy.h"

@interface AboutVC ()<SKStoreProductViewControllerDelegate>

@end

@implementation AboutVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN = YES;
    self.isNeedHideTabBar = YES;
    [self setNavTitle:@"关于"];
    [self.bg1 setImage:areaBgImage];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 评分
- (IBAction)evaluate:(id)sender{
    [self startAview];
    //初始化控制器
    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
    //设置代理请求为当前控制器本身
    storeProductViewContorller.delegate = self;
    //加载一个新的视图展示
    [storeProductViewContorller loadProductWithParameters:
     //appId唯一的
     @{SKStoreProductParameterITunesItemIdentifier : @"910400387"} completionBlock:^(BOOL result, NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self stopAview];
         });
         //block回调
         if(error){
             NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
             POPUPINFO([error localizedDescription]);
         }else{
             //模态弹出appstore
             [APPDELEGATE.mainVC presentViewController:storeProductViewContorller animated:YES completion:^{
                 
             }
              ];
         }
     }];
}

//取消按钮监听
// SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - 检查版本
- (IBAction)checkVersion:(id)sender
{
    [[Harpy sharedInstance]setAppID: @"910400387"];
    [[Harpy sharedInstance]setBelongVC:self];
    [self startAview];
    [[Harpy sharedInstance]checkVersion];
}
@end
