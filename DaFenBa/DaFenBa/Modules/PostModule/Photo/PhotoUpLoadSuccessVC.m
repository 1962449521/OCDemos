//
//  PhotoUpLoadSuccessVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-4.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "PhotoUpLoadSuccessVC.h"
#import "MeHonorVC.h"
#import "MePhotoVC.h"
#import "InviteVC.h"
#import "PostProfile.h"

@interface PhotoUpLoadSuccessVC ()
{
    PostProfile *_postProfile;
}

@end

@implementation PhotoUpLoadSuccessVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)configSubViews
{
    self.isNeedBackBTN = YES;
    [self setNavTitle:@"上传成功"];
    CGRect frame = CGRectMake(25, 10, 29, 24);
    RIGHT_TITLE(frame, nil, nil, @"myAlbum", gotoMePhoto);
    
    PostProfile *postProfile = [[PostManager shareInstance] postProfile];
    UIImage *image = postProfile.post;
    float ratio = image.size.height / image.size.width;
    [self.photoImageView setHeight:self.photoImageView.width *ratio];
    [self.photoImageView setImage:image];
    [self.upperView setHeight:self.photoImageView.height];
    
    
    [self.descriptionLbl setY:self.upperView.bottom + 15];
    self.descriptionLbl.text = postProfile.comment;
    [self.descriptionLbl sizeToFit];
    
    
    [self.downView setY:self.descriptionLbl.bottom +15];
    [self.scrollView setContentSize: CGSizeMake(DEVICE_screenWidth, self.downView.bottom +15)];
    if(postProfile.title)self.titleLabel.text = postProfile.title;
    if(postProfile.brand)self.brandLabel.text = postProfile.brand;
    if(postProfile.texture)self.textureLabel.text = postProfile.texture;
    if(postProfile.highlight)self.highlightLabel.text = postProfile.highlight;
    if(postProfile.buyUrl)self.buyUrlLabel.text = postProfile.buyUrl;
    if(postProfile.buyAddress)self.buyAddressLabel.text = postProfile.buyAddress;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fladeTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewBeginAnimation(3);
        [self.alertView setAlpha:0];
        [UIView commitAnimations];
    });

}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 视图跳转
- (void)backToPreVC:(id)sender
{
    [APPDELEGATE.mainVC dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)watchMyDicibel:(id)sender {
    MeHonorVC *vc = [[MeHonorVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)InviteComment:(UIButton *)sender {
    InviteType type[] = {TypeInviteScore,TypeInviteAdvice};
    InviteVC *inviteVC = [[InviteVC alloc]init];
    inviteVC.type = type[sender.tag];
    inviteVC.postId = [[PostManager shareInstance] postProfile].postId;
    //inviteVC.isHaveSearchBar = YES;
    [self.navigationController pushViewController:inviteVC animated:YES];
}
- (void) gotoMePhoto
{
    MePhotoVC *mePhotoVC = [MePhotoVC new];
    [self.navigationController pushViewController:mePhotoVC animated:YES];
}
@end
