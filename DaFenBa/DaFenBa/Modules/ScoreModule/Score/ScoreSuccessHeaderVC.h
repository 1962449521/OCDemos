//
//  ScoreSuccessHeaderVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-11.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"




@class ScoreManager;

@interface ScoreSuccessHeaderVC : UIViewController



//点击建议时弹出扣除分贝提示
@property (weak, nonatomic) IBOutlet UIView *scoreFinishView;//恭喜你获得1 分页

@property (weak, nonatomic) IBOutlet UIButton *showBigPostBtn;


//照片相关属性
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoIntroLabel;

// 数据展示控件
@property (weak, nonatomic) IBOutlet UILabel *meScoreMatch;
@property (weak, nonatomic) IBOutlet UILabel *meScoreSize;



@property (weak, nonatomic) IBOutlet UILabel *meScoreColor;
@property (weak, nonatomic) IBOutlet UILabel *meScoreGross;
@property (weak, nonatomic) IBOutlet UILabel *avgScore;
@property (weak, nonatomic) IBOutlet UILabel *scoreCount;
@property (weak, nonatomic) IBOutlet UILabel *analyze;

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *photoWrapView;

@property (weak, nonatomic) IBOutlet UILabel *gradeCountLabel;
//---

@property (weak, nonatomic) ScoreManager *scoreManager;

@property (assign, nonatomic) BOOL isOmittedScore;//不提示获取金币

@property (weak, nonatomic) id userDelegate;

- (void) assignValueForControls;

@end
