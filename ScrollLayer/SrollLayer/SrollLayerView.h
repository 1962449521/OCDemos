//
//  SrollLayerView.h
//  SrollLayer
//
//  Created by 胡 帅 on 16/3/9.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataGroup.h"

@protocol SrcollLayerViewDelegate <NSObject>

- (void) scrollLayerAnchorPointChange2:(CGPoint)anchorPoint;

@end

@interface SrollLayerView : UIView

- (void)setDataSource:(NSArray *) arr ;

@property (nonatomic, weak) id<SrcollLayerViewDelegate> delegate;

@end
