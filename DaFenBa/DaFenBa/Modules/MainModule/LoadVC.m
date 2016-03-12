//
//  LoadVCViewController.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-4.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "LoadVC.h"
#import "ConcreteMainVC.h"

@interface LoadVC ()

@end

@implementation LoadVC

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
}
- (void)viewDidAppear:(BOOL)animated
{
    APPDELEGATE.mainVC = [[ConcreteMainVC alloc]init];
    [super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"loadVC disappear");
    [super viewDidDisappear:animated];
}

- (IBAction)loadFinished:(id)sender
{
    NSLog(@"loadFinished");
    
    if (nil == APPDELEGATE.mainVC)
        APPDELEGATE.mainVC = [[ConcreteMainVC alloc]init];
   
    APPDELEGATE.mainVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:APPDELEGATE.mainVC animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            APPDELEGATE.window.rootViewController = APPDELEGATE.mainVC;
            HSLogTrace();
        });
    });
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
