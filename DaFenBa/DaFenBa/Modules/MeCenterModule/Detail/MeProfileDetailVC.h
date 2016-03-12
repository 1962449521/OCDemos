/*!
 @header DetailUserVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */
#import "BaseVC.h"
/*!
 @enum
 @abstract 关于这个enum的一些基本信息
 @constant HelloDocEnumDocDemoTagNumberPopupView PopupView的Tag
 @constant HelloDocEnumDocDemoTagNumberOKButton OK按钮的Tag
 */
@interface MeProfileDetailVC : BaseVC
/*!
 @property
 @abstract 指示当前页是否可编辑
 */

@property (nonatomic, assign) BOOL editable;

@property (nonatomic, weak) IBOutlet UIImageView *bg1;
@property (nonatomic, weak) IBOutlet UIImageView *bg2;
@property (nonatomic, weak) IBOutlet UIImageView *bg3;
@property (nonatomic, weak) IBOutlet UIImageView *bg4;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;


@property (nonatomic, weak) IBOutlet UIImageView *headIcon;


/*
 编辑资料约定
 1头像 长宽相等，除采用第三方头像外，本地上传为120*120
 2性别 “男” / "女"
 3.
 
 */
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;


@end
