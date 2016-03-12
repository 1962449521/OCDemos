//
//  ForgetValidCodeVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-4.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"

@interface ForgetValidCodeVC : BaseVC

@property (nonatomic, strong) NSString *captcha;
@property (nonatomic, strong) NSString *mobile;


@property (nonatomic, weak) IBOutlet UITextField *captchaTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *resetBtn;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@end
