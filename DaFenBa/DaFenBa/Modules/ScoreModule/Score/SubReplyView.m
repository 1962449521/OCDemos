//
//  SubReplyView.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "SubReplyView.h"
#import "ReplyModel.h"
#import "UserProfile.h"
#import<CoreText/CoreText.h>
#import "HomePageVC.h"
#import "ScoreListVC.h"

@implementation SubReplyView
{
    ReplyModel *_model;
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
- (void)assignValue:(ReplyModel *)aReply
{

    _model = aReply;
    self.userId = aReply.srcUser.userId;
    self.userName = aReply.srcUser.name;
    [self.avartar setAvartar:aReply.srcUser.avatar ];
    NSString *content = [NSString stringWithFormat:@"回复@%@: %@",aReply.tgtUser.srcName, aReply.content];
    
    NSRange range1 = [content rangeOfString:@"回复"];
    NSRange range2 = [content rangeOfString:@":"];
    NSRange range;
    if (range1.length > 0 && range2.length > 0) {
        range.location = range1.location + range1.length;
        range.length = range2.location - range1.length+1;
        if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 6.0 ) {
            
            UIColor *textColor = ColorRGB(252.0, 158.0, 85.0);
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:content];
            [str addAttribute:NSForegroundColorAttributeName value:textColor range:range];
            [self.reply setAttributedText:str];

            
        }
        
    }
    
    
    
    
    [self.reply sizeToFit];
    if(self.reply.bottom > self.height)
        [self setHeight:self.reply.bottom];

}
//- (void)layoutSubviews
//{
//        NSRange range1 = [self.reply.text rangeOfString:@"回复"];
//    NSRange range2 = [self.reply.text rangeOfString:@":"];
//    if (range1.length > 0 && range2.length > 0) {
//        NSRange range;
//        range.location = range1.location + range1.length;
//        range.length = range2.location - range.location;
//        if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 6.0 ) {
//            NSMutableAttributedString *richStr = [[NSMutableAttributedString alloc]initWithString: self.reply.text];
//            [richStr addAttribute:(NSString *)kCTForegroundColorAttributeName  value:(id)[UIColor yellowColor].CGColor    range:range];
//            [self.reply setAttributedText:richStr];
//        }
//        
//    }
//}
- (IBAction)viewClicked:(id)sender
{
    [self.delegate replyMessage:_model];
}
- (IBAction)avatarClicked:(id)sender
{
   // POPUPINFO(STRING_fromId(self.userId) );
    id delegateVC = self.delegate;
    [HomePageVC enterHomePageOfUser:_model.srcUser fromVC:(BaseVC *)[delegateVC userDelegate]];
}
@end
