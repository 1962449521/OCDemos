//
//  ScoreModule.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-19.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

@protocol scorePieViewDelegate <NSObject>

- (IBAction)scoreValueChange:(UIControl *)sender withValue:(NSString *)value;

@end


#import "BaseObject.h"
#import "HPieChartView.h"
@class PostProfile;
@class GradeModel;
@class AdviceModel;
@class UserProfile;

@interface ScoreManager : BaseObject<PieChartDelegate>

//将被打分的照片
@property (nonatomic, strong) PostProfile *postProfile;
//打分的结果
@property (nonatomic, strong) GradeModel *postGrade;
//建议的结果
@property (nonatomic, strong) AdviceModel *postAdvice;
//用于控制前翻还是后翻的切入动画
@property BOOL isToPre;
//触发该模块的VC
@property (nonatomic, strong) BaseVC *startVC;

//触发该模块   类方法  自动选择跳转目标：1.我的图片  2.打分页   3.已打分
//当不知道是否已打分时，使用PostProfile类型参数，当知道已打分时，使用scoreManager参数
//当参数为post时，应尽量赋值post.user
//为scoremanager时，必须赋值scoremanager.postProfile 和postGrade
//使用方法[ScoreManager evokeScoreWithPostOrScoreManager:para1 FromVC:para2];
+ (void)evokeScoreWithPostOrScoreManager:(id)postProfileOrScorManager FromVC:(BaseVC *)startVC;
//提交打分
- (void)submitScore:(BaseVC *)submitVC;





/*!
 @method
 @abstract 弹出打分油量盘   可做成类方法呢
 @discussion [[ScoreManager shareInstance] popOutScoreView:(UIButton *)sender wtihValue:(int)value]
 @param sender 调用该方法的按钮控件
 @param value 设置打分油量表的数值
 */
- (void) popOutScoreView:(id)sender withValue:(int)value;


@end
