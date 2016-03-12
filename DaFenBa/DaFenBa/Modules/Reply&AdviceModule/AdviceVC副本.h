//
//  PhotoScoreReplyAdviceVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-12.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"
@class GradeModel;
@class ScoreManager;

@interface AdviceVC : BaseVC

//@property BOOL isSendOut;
//
//@property (strong, nonatomic) NSNumber *adviceId;
//@property (strong, nonatomic) NSString *photoIntroStr;
//@property (strong, nonatomic) NSString *postPhotoUrl;
//@property (strong, nonatomic) NSString *adviceContent;
//@property (strong, nonatomic) NSString *buyAddressStr;
//@property (strong, nonatomic) NSString *buyUrlStr;
//@property (strong, nonatomic) NSString *userNamestr;
//@property (strong, nonatomic) NSString *userId;
//@property (strong, nonatomic) NSString *userAvatarUrl;
//@property (strong, nonatomic) UIImage *postPhotoImage;



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

@property (strong, nonatomic) ScoreManager *scoreManager;
 


@end
