//
//  ScoreSuccessVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-13.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"

@class ScoreManager;
@interface ScoreSuccessVC : BaseVC


@property (strong, nonatomic) IBOutlet UIView *wizardView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIButton *adviceBtn;
@property (weak, nonatomic) IBOutlet UIButton *scoreListBtn;


@property (weak, nonatomic)  UILabel *gradeCountLabel;



@property (nonatomic, strong) ScoreManager *scoreManager;
@property (assign, nonatomic) BOOL isOmittedScore;
@property (assign, nonatomic) BOOL isOmittedCheckPostDetail;

@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *bigPhotoImageView;


@end
