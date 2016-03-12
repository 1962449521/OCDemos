//
//  NSDictionary+RenameKey.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-3.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (RenameKey)
- (void) renameKey:(NSString *)oldKey withNewName:(NSString *)newKey;
@end
