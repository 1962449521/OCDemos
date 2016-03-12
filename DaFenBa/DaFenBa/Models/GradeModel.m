//
//  GradeModel.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-6.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "GradeModel.h"
#import "NetAccess.h"

#import "UserProfile.h"
#import "PostProfile.h"
#import "ReplyModel.h"

@implementation GradeModel



- (void) loadRepliesAtPage:(NSInteger)pageNumber fromTime:(NSNumber *)lastRefreshTime
{
    NetAccess *netAccess =  [NetAccess new];
    /*
     userId: login user id,
     # 	tgtId: grade id,
     postId: post id,
     pager:
     {
     pageNumber: 1,
     pageSize: 20
     },
     lastRefreshTime: last refresh time for access first page
     */
    if(self.replies)
        return;
    NSNumber *userId = [Coordinator userProfile].userId;
    if(userId == nil || [userId intValue] == 0)
        userId = @47;
    NSNumber *tgtId  = self.gradeId;
    NSNumber *postId = self.post.postId;
    
    NSDictionary *para = @{@"userId" : userId, @"tgtId" : tgtId, @"postId" : postId, @"pager" : @{@"pageNumber": [NSNumber numberWithInt:pageNumber], @"pageSize" : @3}, @"lastRefreshTime" : lastRefreshTime};
    
    NSDictionary *resultDic = [netAccess passUrl:ReplyModule_grade_reply_list andParaDic:para withMethod:ReplyModule_grade_reply_list_method andRequestId:ReplyModule_grade_reply_list_tag thenFilterKey:nil useSyn:YES dataForm:7];
    NSDictionary *result = resultDic[@"result"];
    if (NETACCESS_Success) {
        NSNumber *recordCount = resultDic[@"pager"][@"recordCount"];
        self.repliesCount = recordCount;
        NSMutableArray *replies = [NSMutableArray array];
        if (recordCount > 0) {
            self.replies = [NSMutableArray array];
            NSArray *repliesArr = resultDic[@"postReplies"];
            for (NSDictionary *aReplyDic in repliesArr) {
                NSMutableDictionary *aReplyDicM = [aReplyDic mutableCopy];
                [aReplyDicM renameKey:@"id" withNewName:@"replyId"];
                ReplyModel *aReply = [ReplyModel new];
                [aReply assignValue:aReplyDicM];
                
                
                UserProfile *user = [UserProfile new];
                NSMutableDictionary *srcUserDic = aReplyDic[@"srcUser"];
                [srcUserDic renameKey:@"id" withNewName:@"replyId"];
                [user assignValue:srcUserDic];
                aReply.srcUser = user;
                
                user = [UserProfile new];
                NSMutableDictionary *tgtUserDic = aReplyDic[@"tgtUser"];
                [srcUserDic renameKey:@"id" withNewName:@"replyId"];
                [user assignValue:tgtUserDic];
                aReply.tgtUser = user;
                [replies addObject:aReply];
            }
            if (pageNumber == 1) {
                self.replies = replies;
            }
            else
            {
                if (self.replies == nil) {
                    self.replies = [NSMutableArray array];
                }
                [self.replies addObjectsFromArray:replies];
            }
        }
    }
}

@end
