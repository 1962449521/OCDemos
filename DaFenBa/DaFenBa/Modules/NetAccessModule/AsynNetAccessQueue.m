//
//  NetAccessQueque.m
//  testNetwork
//  管理异步请求队列
//  Created by SookinMac05 on 14-5-15.
//  Copyright (c) 2014年 sookin. All rights reserved.
//

#import "AsynNetAccessQueue.h"
#import "AsynNetAccessQueueConst.h"
#import "ASIHTTPRequest.h"

@implementation AsynNetAccessQueue

+ (id)shareAsynNetAccessQueque
{
    static dispatch_once_t once;
    static AsynNetAccessQueue *queue;
    dispatch_once(&once, ^{queue = [self queue];});
    [queue setShouldCancelAllRequestsOnFailure:CancelAllRequestsOnFailure];
    [queue setMaxConcurrentOperationCount:MaxConcurrentOperationCount];
    return queue;
}

+ (void)addRequest:(ASIHTTPRequest *)request
{
    ASIHTTPRequest *existRequest = [self requestfromId:request.requestID];
    if (existRequest != nil && ![existRequest isCancelled] && ![existRequest complete]) {
        return;
    }
    [[self shareAsynNetAccessQueque]addOperation:request];
    [self go];
    //NSLog(@"Current requst num in queue:%d ",[[self shareAsynNetAccessQueque]requestsCount]);
}

+ (BOOL)existRequestId:(NSNumber *)requestId
{
    NSArray *requests = [[self shareAsynNetAccessQueque] operations];
    ASIHTTPRequest *request;
    NSEnumerator *enumerater = [requests objectEnumerator];
    while (request = [enumerater nextObject ]) {
        if (request.requestID == requestId)
        {
            return YES;
            break;
        }
    }
    return NO;
}

+ (ASIHTTPRequest *)requestfromId:(NSNumber *)requestId
{
    NSArray *requests = [[self shareAsynNetAccessQueque] operations];
    ASIHTTPRequest *request;
    NSEnumerator *enumerater = [requests objectEnumerator];
    while (request = [enumerater nextObject ]) {
        if (request.requestID == requestId )
        {
            return request;
            break;
        }
    }
    return nil;
}

+ (void)cancelRequestWithId:(NSNumber *)requestId
{
    if ([self existRequestId:requestId])
    {
        ASIHTTPRequest *request = [self requestfromId:requestId];
        [request cancel];
    }
}

+ (void)cancelAll
{
    [[self shareAsynNetAccessQueque]cancelAllOperations];
}

+ (void)go
{
    [[self shareAsynNetAccessQueque]go];
}

+ (int)count
{
    return [[self shareAsynNetAccessQueque]requestsCount];
}

+ (BOOL)isAllCompletedOrCancelled
{
    NSArray *requests = [[self shareAsynNetAccessQueque] operations];
    ASIHTTPRequest *request;
    NSEnumerator *enumerater = [requests objectEnumerator];
    while (request = [enumerater nextObject ]) {
        if (!request.isCancelled && !request.complete )
        {
            return NO;
            break;
        }
    }
    return YES;
}
@end
