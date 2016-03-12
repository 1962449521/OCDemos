/*!
 @header MeHonorVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import "BaseVC.h"
#import "XHPullRefreshTableViewController.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */
@interface MeHonorVC : BaseVC

@property (nonatomic, weak) IBOutlet UIImageView * headIcon;

@property (nonatomic, weak) IBOutlet UIImageView * genderIcon;


@property (nonatomic, weak) IBOutlet UIButton *rankButton;

@property (nonatomic, weak) IBOutlet UILabel * userName;

@property (nonatomic, weak) IBOutlet UILabel * medalCount;

//@property (nonatomic, weak) IBOutlet UIScrollView *medalScrollView;

@property (nonatomic, weak) IBOutlet UILabel * decibelCountLabel;
@property (nonatomic, weak) IBOutlet UIButton *honorBtn1;//打分 medal id = 1

@property (nonatomic, weak) IBOutlet UIButton *honorBtn2;//建议 medal id = 2

@property (nonatomic, weak) IBOutlet UIButton *honorBtn3;//分享 medal id = 3

@property (nonatomic, weak) IBOutlet UIImageView *bg1;

@property (nonatomic, weak) IBOutlet UIImageView *bg2;
@property (weak, nonatomic) IBOutlet UIImageView *strechIcon;
@property (weak, nonatomic) IBOutlet UIView *upperView;

@property (nonatomic, strong) XHPullRefreshTableViewController *tableVC;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

//数据控件


@end
