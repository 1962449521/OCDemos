//
//  SecurityPhone.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-2.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"

@interface SecurityPhoneVC : BaseVC

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIImageView *bg1;
@property (nonatomic, weak) IBOutlet UIImageView *bg2;
@property (nonatomic, weak) IBOutlet UIImageView *bg3;

@property (nonatomic, weak) IBOutlet UIButton *sendBtn;

@property (nonatomic, weak) IBOutlet UITextField *phoneNumTextField;
@property (nonatomic, weak) IBOutlet UITextField *validCodeTextField;

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@end
