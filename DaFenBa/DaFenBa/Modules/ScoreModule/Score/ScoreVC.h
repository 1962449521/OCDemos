//
//  DetaiPhoto.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-5.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"

@interface ScoreVC : BaseVC<scorePieViewDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *bigPhotoImageView;


@property (nonatomic, weak) IBOutlet UISlider *slider;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
//保存打分的三个量值
@property int value1;
@property int value2;
@property int value3;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoIntro;
@property (weak, nonatomic) IBOutlet UIView *clothesDetailView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
//衣服详情
@property (weak, nonatomic) IBOutlet UILabel *clothesTitle;
@property (weak, nonatomic) IBOutlet UILabel *clothesBrand;
@property (weak, nonatomic) IBOutlet UILabel *clothesTexture;
@property (weak, nonatomic) IBOutlet UILabel *clothesHighLight;
@property (weak, nonatomic) IBOutlet UILabel *clothesBuyUrl;
@property (weak, nonatomic) IBOutlet UILabel *clothesStorePlace;

@property (strong, nonatomic) IBOutlet UIView *wizardView;

@property (strong, nonatomic) ScoreManager *scoreManager;
- (void) refreshDetails;
@end
