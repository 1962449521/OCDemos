//
//  PhotoScoreReplyAdviceVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-12.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"
@class GradeModel;


@interface AdviceVC : BaseVC



@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet UILabel *photoIntro;
@property (weak, nonatomic) IBOutlet UILabel *adviceTitle;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextView *advice;
@property (weak, nonatomic) IBOutlet UITextField *buyAddress;
@property (weak, nonatomic) IBOutlet UITextField *buyUrl;
@property (weak, nonatomic) IBOutlet UIView *sectionHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;

@property (weak, nonatomic) IBOutlet UIImageView *postPhoto;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *bigPhotoImageView;
@property (weak, nonatomic) IBOutlet UIView *upperView;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UITextField *sendTextField;

@property (strong, nonatomic) id gradeOrScormanager;//当由打分进入时，提供的是ScoreManager //其他情况提供grade

@property (assign, nonatomic)  BOOL p_isSendOut;//两种界面，YES时只提供编辑区输入
@property (strong, nonatomic) NSMutableArray *dataSource;//聊天区数据源
@end
