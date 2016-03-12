
/*!
 @header HomePageVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import <UIKit/UIKit.h>
#import "XHPullRefreshTableViewController.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface HomePageVC : BaseVC<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *upperView;
@property (nonatomic, weak) IBOutlet UIView *downView;
@property (nonatomic, weak) IBOutlet UIView *operateView;
@property (nonatomic, weak) IBOutlet UIView *filterView;
@property (nonatomic, weak) IBOutlet UIButton *editBtn;
@property (nonatomic, weak) IBOutlet UIButton *sendLetterBtn;
@property (nonatomic, weak) IBOutlet UIButton *guangzuBtn;

//数据前台显示
@property (nonatomic, weak) IBOutlet UIImageView * avatarImageView;
@property (nonatomic, strong) XHPullRefreshTableViewController *tableVC;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (nonatomic, weak) IBOutlet UILabel *recordCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansCountLabel;
//用户信息
@property (nonatomic, strong) UserProfile *userProfile;

//@property (nonatomic, assign) NSInteger type;//type=0 admin  type = 1 guest
//@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSArray *filterNameArray;
//#pragma mark - 模板特有方法 需子类重写
//- (void)AlternativeEditOrFollowSend;

+ (void)enterHomePageOfUser:(UserProfile *)user fromVC:(BaseVC *)startVC;

@end
