/*!
 @header MePhotoCell.h
 @abstract 我的相片单元格
 @author 胡帅
 @version 1.0 2014/08 Creation
 */


#import <UIKit/UIKit.h>
#import "MePhotoCellModel.h"

/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface MePhotoCell : UICollectionViewCell

/*!
 @property
 @abstract 所发布的照片
 */
@property (weak, nonatomic) IBOutlet UIImageView *post;
@property (weak, nonatomic) IBOutlet UILabel *bageComment;
@property (weak, nonatomic) IBOutlet UILabel *bageAdvice;
@property (weak, nonatomic) IBOutlet UILabel *avgGrade;

@property (nonatomic, strong) id userDelegate;
- (void)assignValue:(id)cellData;
- (IBAction)tap:(id)sender;
- (IBAction)longPress:(id)sender;



@end
