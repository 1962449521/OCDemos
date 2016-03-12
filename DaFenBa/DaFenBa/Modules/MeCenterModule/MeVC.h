
/*!
 @header MeVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import "BaseVC.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface MeVC : BaseVC

//3个背景图设置 无关紧要 属性不列入文档
@property (nonatomic,weak) IBOutlet UIImageView *bg1;
@property (nonatomic,weak) IBOutlet UIImageView *bg2;
@property (nonatomic,weak) IBOutlet UIImageView *bg3;
@property (nonatomic,weak) IBOutlet UIView *bageFan;

//数据前台显示控件
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *rankButton;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *followCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *CommentCountLabel;



//是否由tab栏的切换进入该界面
@property(nonatomic, assign) BOOL isTabChangeIn;


@end
