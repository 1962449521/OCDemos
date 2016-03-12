/*!
 @header BigFieldVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */
#import <UIKit/UIKit.h>
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface BigFieldVC : UIViewController<pickerVCDelegate>


@property NSUInteger id;

@property NSUInteger maxCharacterNum;
//遮盖背景
@property BOOL isMaskBG;
@property BOOL isUseSmallLayout;


@property (nonatomic, strong) NSString *placeHolderStr;

@property (nonatomic, strong) NSString *value;

@property (nonatomic, weak) IBOutlet UILabel *titlelable;

@property (nonatomic, strong) NSString  *titlestr;

@property (nonatomic, weak) IBOutlet UITextView *textView;

@property (nonatomic, weak) IBOutlet UILabel *placeHolderLabel;

@property BOOL isNeedGotoNext;

@property id<pickerUserDelegate>userDelegate;

@property (weak, nonatomic) IBOutlet UIView *smallLayout;
@property (weak, nonatomic) IBOutlet UITextField *smallTextField;

- (void)show;

- (void)hide;


@end
