/*!
 @header HomeContentCell.h
 @abstract 首页图片单元格
 @author 胡帅
 @version 1.0 2014/08 Creation
 */


#import <UIKit/UIKit.h>
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface HomeContentCell : UICollectionViewCell

@property int indexWinthDataSource;
/*!
 @property
 @abstract 头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *headIcon;
/*!
 @property
 @abstract 用户名
 */
@property (weak, nonatomic) IBOutlet UILabel *name;
/*!
 @property
 @abstract 性别
 */
@property (weak, nonatomic) IBOutlet UIImageView *gender;
/*!
 @property
 @abstract 所发布的照片
 */
@property (weak, nonatomic) IBOutlet UIImageView *photo;
/*!
 @property
 @abstract 照片简介
 */
@property (weak, nonatomic) NSString *photoIntro;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UIImageView *gradeCountIcon;
@property (weak, nonatomic) IBOutlet UIImageView *disctanceIcon;


@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *gradeCountLabel;

/*!
 @property
 @abstract 照片所属人的usrId
 */
@property (strong, nonatomic) NSString *userId;

@property (strong, nonatomic) NSString *postId;


- (void)assignValue:(PostProfile *)contentModel;
@end
