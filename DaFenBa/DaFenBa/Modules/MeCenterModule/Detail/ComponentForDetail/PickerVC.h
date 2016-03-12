/*!
 @header GenderPickerVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */


#import <UIKit/UIKit.h>
/*!
 @enum
 @abstract 关于这个enum的一些基本信息
 @constant
 @constant
 */
typedef enum PickerType{
    typeDataPicker,
    typeSinglepicker,
    typeLocationPicker
}PickerType;





/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface PickerVC : UIViewController<pickerVCDelegate>

@property NSUInteger id;

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@property (nonatomic, weak) IBOutlet UIDatePicker *dataPickerView;

@property (nonatomic, strong) NSArray *singleSource;

@property (nonatomic, weak) IBOutlet UILabel *titlelable;

@property (nonatomic, strong) NSString  *titlestr;

@property (nonatomic, strong) NSString *value;

@property PickerType pickerType;

@property BOOL isNeedGotoNext;

@property id<pickerUserDelegate>userDelegate;

- (void)show;

- (void)hide;

- (void)reNewControl;

@end
