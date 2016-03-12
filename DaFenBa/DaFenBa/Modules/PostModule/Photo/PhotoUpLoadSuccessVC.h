//
//  PhotoUpLoadSuccessVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-4.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"

@interface PhotoUpLoadSuccessVC : BaseVC



@property (nonatomic,strong) IBOutlet UIImageView *photoImageView;
@property (nonatomic,strong) IBOutlet UILabel *descriptionLbl;
@property (nonatomic,strong) IBOutlet UIView *upperView;

@property (nonatomic,strong) IBOutlet UIView *downView;

@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *textureLabel;
@property (weak, nonatomic) IBOutlet UILabel *highlightLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyUrlLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyAddressLabel;

@end
