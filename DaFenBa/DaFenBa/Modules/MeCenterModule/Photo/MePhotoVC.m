//
//  MePhotoVCViewController.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-31.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//
#define mePhtoCellSpace 5.0


#import "MePhotoVC.h"
#import "PostProfile.h"
#import "MePhotoCell.h"

@interface MePhotoVC ()

@end

@implementation MePhotoVC
{
    UIView *loadMoreView;
    UILabel *countLabel;
//    int count;
    NSNumber *maxPage;
    NSNumber *lastRequestTime;
    
    PostProfile *tgtpostProfile;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        lastRequestTime = @0;
        maxPage = @8;
        self.dataSource = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"我的照片"];
    self.isNeedBackBTN = YES;
    self.isNeedHideTabBar = YES;
    [self.view setBackgroundColor:ThemeBGColor_gray];
    [self.collectionView setBackgroundColor:ColorRGB(255.0, 255.0, 255.0)];
    [self.view setHeight:DEVICE_screenHeight - 20 - 44];
    countLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    countLabel.text = @"全部照片（...）";
    countLabel.font = [UIFont systemFontOfSize:14];
    countLabel.textColor = textGrayColor;
    countLabel.backgroundColor = [UIColor clearColor];
    int countLabelHeight = 28.0;
    [countLabel sizeToFit];
    [countLabel setWidth:300];
    [countLabel setHeight:countLabelHeight];
    [countLabel setX:12];
    [self.view addSubview:countLabel];
    
    [self.collectionView setFrame:self.view.bounds];
    [self.collectionView setY:countLabelHeight];
    [self.collectionView setHeight:self.collectionView.height - countLabelHeight];

    if (self.pullDownRefreshed) {
        [self setupRefreshControl];
    }
    loadMoreView = self.customRefreshControl.loadMoreView;
    [loadMoreView setY: self.view.height - loadMoreView.height];
    //刷新一次
    [self.collectionView setContentOffset:CGPointMake(0, -refreshViewHeight)];
    [self startPullDownRefreshing];

}

#pragma mark - loadDataSource
- (void)loadDataSource
{
    if (self.requestCurrentPage == 0 && [maxPage intValue] == 0) {
        maxPage = @30000;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //没有更多页
        if(self.requestCurrentPage + 1 > [maxPage intValue])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self endMoreOverWithMessage:@"没有更多页了"];
            });
            return;
        }
        
        NSNumber *userId = [Coordinator userProfile].userId;
        
        NSMutableDictionary *para = [@{ @"pager" : @{@"pageNumber": NUMBER(self.requestCurrentPage + 1), @"pageSize" : @20}, @"lastRefreshTime" : lastRequestTime} mutableCopy];
        if (userId)
            [para setObject:userId forKey:@"userId"];
        NetAccess *netAccess = [NetAccess new];
        NSDictionary *resultDic = [netAccess passUrl:PostModule_myPostList andParaDic:para withMethod:PostModule_myPostList_method andRequestId:PostModule_myPostList_tag thenFilterKey:nil useSyn:YES dataForm:7];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self revokeHsRefresh];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {
                NSArray *postResponseArr = resultDic[@"posts"];
                NSMutableArray *postArr ;
                
                
                if(resultDic[@"lastRefreshTime"] != nil)
                {
                    lastRequestTime = resultDic[@"lastRefreshTime"];
                    if(resultDic[@"pager"][@"pageCount"] != nil)
                        maxPage = resultDic[@"pager"][@"pageCount"];
                    UserProfile *userProfile = [Coordinator userProfile];
                    if(!userProfile.extInfo) userProfile.extInfo = [NSMutableDictionary dictionary];
                    [userProfile.extInfo setValue:resultDic[@"pager"][@"recordCount"] forKey:@"postCount"];
                }
                if(postResponseArr && [postResponseArr count] > 0)
                {
                    postArr = [NSMutableArray array];
                    for (NSDictionary *dic in postResponseArr) {
                        PostProfile *post = [PostProfile new];
                        NSMutableDictionary *dic2 = [dic mutableCopy];
                        [dic2 renameKey:@"id" withNewName:@"postId"];
                        [post assignValue:dic2];
                        post.user = [Coordinator userProfile];
                        [postArr addObject:post];
                    }
                }
                if (self.requestCurrentPage == 0) {
                    [self.dataSource  addObjectsFromArray:postArr];
                }
                else{
                    [self.dataSource removeAllObjects];
                    [self.dataSource addObjectsFromArray:postArr];
                }
                [self.collectionView reloadData];
            }
            else
            {
                POPUPINFO(@"数据加载失败");
                [self revokeHsLoadMore];
            }
        });
    });
}
#pragma mark - 删除照片
- (void)deleteCell:(PostProfile *)postProfile
{
    tgtpostProfile = postProfile;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定要删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self deleteCell0:tgtpostProfile];
    }
}
- (void)deleteCell0:(PostProfile *)postProfile
{
    NSNumber *userId = [Coordinator userProfile].userId;
    NSNumber *postId = postProfile.postId;
    NSDictionary *para = @{@"post" : @{@"id" : postId, @"userId" : userId}};
    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NetAccess *netAccess = [[NetAccess alloc]init];
        NSDictionary *resultDic = [netAccess passUrl:PostModule_delete andParaDic:para withMethod:PostModule_delete_method andRequestId:PostModule_delete_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {
                NSDictionary *extInfo = [Coordinator userProfile].extInfo;
                int oldCount = [extInfo[@"postCount"] intValue];
                [self.dataSource removeObject:postProfile];
                POPUPINFO(@"删除成功！");
                
                [extInfo setValue:NUMBER(oldCount - 1) forKey:@"postCount"];
                [self.collectionView reloadData];
            }
            else
            {
                POPUPINFO(@"删除失败！");
            }
        });
    });
    
}

#pragma mark UICollectionViewDataSource
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    UserProfile *user = [Coordinator userProfile];
    if (user.extInfo[@"postCount"])
        countLabel.text = [NSString stringWithFormat:@"全部照片（%d）", [user.extInfo[@"postCount"] intValue]];
    return [self.dataSource count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MePhotoCell";
    UINib *nib = [UINib nibWithNibName:cellIdentifier bundle:[NSBundle mainBundle]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:cellIdentifier];
    MePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier
                                                     owner:self options:nil];
        for (id oneObject in nib) {
            if ([oneObject isKindOfClass:[UICollectionViewCell class]]) {
                cell = oneObject;
                break;
            }
        }
    }
    cell.userDelegate = self;
    PostProfile *model = self.dataSource[indexPath.row];
    [cell assignValue:model];
    return cell;
    
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150, 187);

}

@end
