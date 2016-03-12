//
//  HomeContentView.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "HomeContentCell.h"
#import "NSNumber+DaFenBaDistance.h"
#import "PostProfile.h"

@implementation HomeContentCell
{
    UIView *hitView;
    BOOL isClick;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - assign Value
- (void)assignValue:(PostProfile *)contentModel
{
    self.userId = @"123433";
    //NSString *str = contentModel.photo;
    float ratio = [contentModel.picH floatValue]/[contentModel.picW floatValue];
    float height = 150.0 * ratio;
    CGSize size = {150, height};
    [self.photo setSize:size];
    self.photo.clipsToBounds = YES;
    [self.photo setPost:contentModel.pic];
    self.photo.contentMode = UIViewContentModeScaleToFill;
    [self.scoreView setBottom:self.photo.bottom];
    NSNumber *numDistance = contentModel.distance;
    
    NSString *strDistance = [numDistance daFenBaDistance];
    self.distanceLabel.text = strDistance;
    self.gradeCountLabel.text =STRING_joint(STRING_fromInt([contentModel.gradeCount intValue]), @"人打分");
    [self.gradeCountLabel sizeToFit];
    [self.gradeCountLabel setRight:self.width- 5];
    [self.gradeCountLabel setCenter:CGPointMake(self.gradeCountLabel.center.x, 10.0)];
    [self.gradeCountIcon setRight:self.gradeCountLabel.left - 2];
    
    [self.descriptionLabel setY:self.scoreView.bottom + 5.0];
    NSString *desStr = contentModel.comment;
    //    self.photoIntro = [NSString stringWithString:desStr];
    //    CGSize newSize = CGSizeMake(self.descriptionLabel.width, 200);
    //    while ([desStr sizeWithFont:self.descriptionLabel.font constrainedToSize: newSize].height > self.descriptionLabel.height/2){
    //        desStr = [desStr substringToIndex:desStr.length - 1];
    //    }
    //    NSString *desStr2 = [contentModel.description substringToIndex:desStr.length + 6];
    //    self.descriptionLabel.text = STRING_joint(desStr2, @"...");
    self.descriptionLabel.text = desStr;
    
    
    
        self.layer.borderColor = [TheMeBorderColor CGColor];
        self.layer.borderWidth = 1.0;
    [self setHeight:self.descriptionLabel.bottom + 5.0];
    

    
}
@end
