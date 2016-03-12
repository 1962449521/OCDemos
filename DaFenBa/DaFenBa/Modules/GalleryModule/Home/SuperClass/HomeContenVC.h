/*!
 @header HomeContentVC.h
 @abstract 主页三个栏目的视图控制器的共同父类
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

 
#import "HSRefreshCollectionViewController.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface HomeContenVC : HSRefreshCollectionViewController
{
@protected
    BOOL _isRefreshFinished;
    float oldOffsetY;
    UIView *loadMoreView;
    NSNumber *maxPage;
@public
    NSNumber *lastRequestTime;
    
}

- (void)viewDidCurrentView;

- (void)loadDataSource;


#pragma mark UICollectionViewDataSource
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
@end