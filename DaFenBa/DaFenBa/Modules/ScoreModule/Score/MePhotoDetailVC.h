//
//  MePhotoDetailVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-17.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//
#import "BaseVC.h"
#import <UIKit/UIKit.h>
@class PostProfile;
@interface MePhotoDetailVC : BaseVC

@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *bigPhotoImageView;

@property (strong, nonatomic) IBOutlet UIView *headerView;

//照片相关属性
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoIntroLabel;
@property (weak, nonatomic) IBOutlet UIView *photoWrapView;

@property (nonatomic, weak) IBOutlet UIImageView *bg1;
@property (nonatomic, weak) IBOutlet UIButton *bg2;

@property (nonatomic, weak) IBOutlet UIView *scoreWrapView;
@property (weak, nonatomic) IBOutlet UILabel *adviceCount;
@property (weak, nonatomic) IBOutlet UILabel *avgScore;
@property (weak, nonatomic) IBOutlet UILabel *scoreCount;

@property (weak, nonatomic) IBOutlet UIView *postDetailView;
@property (weak, nonatomic) IBOutlet UIView *gradeCountWrapView;

@property (nonatomic, weak) IBOutlet UIImageView *strechIcon;
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;

@property (weak, nonatomic) IBOutlet UITextField *brandLabel;
@property (weak, nonatomic) IBOutlet UITextField *textureLabel;
@property (weak, nonatomic) IBOutlet UITextField *highlightLabel;
//@property (weak, nonatomic) IBOutlet UITextField *buyUrlLabel;
//@property (weak, nonatomic) IBOutlet UITextField *storeLabel;

@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *gradeCountLabel;
@property (strong, nonatomic)  PostProfile *postProfile;

@property (assign, nonatomic) BOOL isOmittedCheckPostDetail;
@property (weak, nonatomic) id userDelegate;

- (void)replyMessage:(NSDictionary *)info;
- (void)refreshGrade:(GradeModel *)grade;



@end