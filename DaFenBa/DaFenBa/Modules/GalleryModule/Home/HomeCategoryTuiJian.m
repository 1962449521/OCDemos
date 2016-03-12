//
//  HomeCategoryTuiJian.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-26.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//


// MARK: 如需测试接口 请设置如下宏

#define isMOCKDATADebugger NO
#define SLEEP 


#import "HomeCategoryTuiJian.h"
//#import "TuiJianSectionHeaderView.h"
#import "WaterFallFooter.h"
#import "HomeVC.h"

@interface HomeCategoryTuiJian ()

@end

@implementation HomeCategoryTuiJian


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidCurrentView
{
    [super viewDidCurrentView];
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - dataSource

/*
 uncomment to support a header view
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    HSLog(@"collectionViewCell draw begin!row:%i", indexPath.row);
    UICollectionReusableView *reusableView ;
    if ([kind isEqualToString:WaterFallSectionHeader])
    {
        UINib *nib = [UINib nibWithNibName:@"TuiJianSectionHeaderView" bundle:[NSBundle mainBundle]];
        [collectionView registerNib:nib forSupplementaryViewOfKind:WaterFallSectionHeader withReuseIdentifier:WaterFallSectionHeader];
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:WaterFallSectionHeader
                                                                 forIndexPath:indexPath];
        if(reusableView == nil)
            reusableView = (UICollectionReusableView *)[[[NSBundle mainBundle]loadNibNamed:@"TuiJianSectionHeaderView" owner:self options:nil]lastObject];
    }
    else if ([kind isEqualToString:WaterFallSectionFooter])
    {
        [collectionView registerClass:[WaterFallFooter class] forSupplementaryViewOfKind:WaterFallSectionFooter withReuseIdentifier:WaterFallSectionFooter];
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:WaterFallSectionFooter forIndexPath:indexPath];
    }
    return reusableView;
    HSLog(@"collectionViewCell draw begin!");
}
*/


@end
