//
//  NetAccessModuleDelegate.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-5.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import <Foundation/Foundation.h>


//==================调用本框架的异步访问时，调用方实现的协议===========================
@protocol AsynNetAccessDelegate<NSObject>
@optional
- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId;
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId;
//==================================================================================
@end



@protocol NetAccessModuleDelegate <NSObject>

@property (nonatomic, weak) id<AsynNetAccessDelegate> delegate;

- (id)passUrl:(NSString *)urlstr andParaDic:(NSDictionary *)paraDic withMethod:(AccessMethod)accessMehod andRequestId:(NSNumber *)requestId thenFilterKey:(NSString *)filterKey useSyn:(BOOL)isSyn dataForm:(NSUInteger)dataForm;

@end
