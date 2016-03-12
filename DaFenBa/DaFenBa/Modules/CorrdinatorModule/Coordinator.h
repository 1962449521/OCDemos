//
//  Corrdinator.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-9.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"
#import "DaFenBaSecurity.h"
#import "DaFenBaMember.h"

#define AES_encode(str, aeskey, giv) [Coordinator AES128Encrypt:str key:aeskey Iv:giv ]
#define AES_decode(str, aeskey, giv) [Coordinator AES128Decrypt:str key:aeskey Iv:giv ]




@interface Coordinator : BaseObject<SecurityModuleDelegate, MemberModuleFacadeDelegate>
#pragma mark - SecurityModuleDelegate
/*
 .
 .
 */
#pragma mark - MemberModuleFacadeDelegate
/*
 .
 .
 */
#pragma mark - push follow refresh
/**
 *	@brief	关注内容新增时更新标志
 *  @abstrat [Coordinator followGategoryRefeshed];
 */
//+ (void)followCategoryRefeshed;


#pragma mark - message count num
+ (void)setMessageBadgeCount:(NSString *)count;



@end
