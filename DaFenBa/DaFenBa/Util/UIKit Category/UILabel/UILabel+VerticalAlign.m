//
//  UILabel+VerticalAlign.m
//  testSrollTextView
//
//  Created by 胡 帅 on 14-4-19.
//  Copyright (c) 2014年 sookin. All rights reserved.
//

#import "UILabel+VerticalAlign.h"

@implementation UILabel(VerticalAlign)
-(void)alignTop {
    CGSize fontSize = [@"一行" sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, INT64_MAX) lineBreakMode:NSLineBreakByWordWrapping];//单行高度[self.text sizeWithFont:self.font];
    double finalHeight = self.frame.size.height;//fontSize.height *self.numberOfLines;
    double finalWidth =self.frame.size.width;//expected width of label
    CGSize theStringSize =[self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, 2000) lineBreakMode:self.lineBreakMode];
    int newLinesToPad =(finalHeight - theStringSize.height)/ fontSize.height;
        for(int i=0; i<newLinesToPad; i++)
        self.text =[self.text stringByAppendingString:@"\n "];
}

-(void)alignBottom {
    CGSize fontSize =[self.text sizeWithFont:self.font];
    double finalHeight = fontSize.height *self.numberOfLines;
    double finalWidth =self.frame.size.width;//expected width of label
    CGSize theStringSize =[self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    int newLinesToPad =(finalHeight - theStringSize.height)/ fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text =[NSString stringWithFormat:@" \n%@",self.text];
}
@end

