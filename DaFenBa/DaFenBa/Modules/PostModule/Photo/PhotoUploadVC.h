//
//  PhotoUploadVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-4.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"

@protocol PhotoUploadDelegate <NSObject>
@optional
- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion;
@end


@interface PhotoUploadVC : BaseVC

@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *bigPhotoImageView;



@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIImageView *photo;
@property (nonatomic, weak) IBOutlet UILabel *placeHolderLabel;

@property (nonatomic, weak) IBOutlet UIView *upperView;
@property (nonatomic, weak) IBOutlet UIView *downView;

@property (nonatomic, weak) IBOutlet UIImageView *bg1;
@property (nonatomic, weak) IBOutlet UIImageView *bg2;
@property (nonatomic, weak) IBOutlet UIImageView *bg3;

@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@property (nonatomic, weak) IBOutlet UIImageView *strechIcon;

@property (nonatomic, weak) IBOutlet UIButton *sendBtn;



@property (nonatomic, assign) BOOL isStreched;
//@property (nonatomic, strong) NSString *locationStr;


@property NSUInteger maxCharacterNum;

@property (nonatomic, weak) id<PhotoUploadDelegate> uploadDelegate;
//用户输入
@property (weak, nonatomic) IBOutlet UITextView *photoIntroTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *brandLabel;
@property (weak, nonatomic) IBOutlet UITextField *textureLabel;
@property (weak, nonatomic) IBOutlet UITextField *highlightLabel;
@property (weak, nonatomic) IBOutlet UITextField *buyUrlLabel;
@property (weak, nonatomic) IBOutlet UITextField *storeLabel;


@end
