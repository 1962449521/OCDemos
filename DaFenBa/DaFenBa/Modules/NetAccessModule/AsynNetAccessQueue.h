
/*!
 @header AsynNetAccessQueue.h
 @abstract 异步加载队列管理
 @author 胡 帅
 @version 1.00 2014/05 Creation
 */

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"


@interface AsynNetAccessQueue :ASINetworkQueue

+ (void)addRequest:(ASIHTTPRequest *)request;

+ (void)cancelRequestWithId:(NSNumber *)requestId;

+ (void)cancelAll;

+ (void)go;

+ (int)count;

+ (BOOL)isAllCompletedOrCancelled;

@end
