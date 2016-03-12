/*!
 @header PersonListVCl.h
 @abstract 人员列表类的父类
 @author 胡帅
 @version 1.0 2014/08 Creation
 */
/*!
 @enum
 @abstract 关于这个enum的一些基本信息
 @constant HelloDocEnumDocDemoTagNumberPopupView PopupView的Tag
 @constant HelloDocEnumDocDemoTagNumberOKButton OK按钮的Tag
 */
typedef enum InviteType
{
    TypeInviteScore,
    TypeInviteAdvice
}InviteType;

#import "BaseVC.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */
@interface InviteVC : BaseVC

@property (nonatomic, strong) NSMutableArray *tableVCArr;
//@property BOOL isHaveSearchBar;
@property InviteType type;
@property (nonatomic, strong) NSNumber *postId;
@end
