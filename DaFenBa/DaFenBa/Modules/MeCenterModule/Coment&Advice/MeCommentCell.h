//
//  MeCommentCell.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-31.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MeCommentCellUserDelegate <NSObject>

- (void) commentLongClick:(NSInteger)index;
- (void) adviceLongClick:(NSInteger)index;
- (void) commentClick:(NSInteger)index;
- (void) adviceClick:(NSInteger)index;
- (void) postClick:(NSInteger)index;
- (void) deleteCell:(NSInteger)index;
- (void) shareCell:(NSInteger)index;
@end


@interface MeCommentCell : BaseCell
@property (weak, nonatomic) IBOutlet UIImageView *cellBgView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIImageView *photo;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *adviceLabel;
@property (weak, nonatomic) IBOutlet UIView *postBtn;

@property (weak, nonatomic) IBOutlet UIView *commentBtn;
@property (weak, nonatomic) IBOutlet UIView *adviceBtn;
@property (weak, nonatomic) IBOutlet UIButton *garbageBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *meGradeLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgGradeBtn;

@property (nonatomic, assign) NSInteger indextWithinDataSource;

@property (weak, nonatomic) id<MeCommentCellUserDelegate>delegate;



@end
