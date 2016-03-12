//
//  TextFieldValidator.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-9.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"

@interface TextFieldValidator : BaseObject
@property (nonatomic, strong) NSPredicate *pred;
@property (nonatomic, strong) NSString *erroMsg;
//+ (TextFieldValidator *) TallValidator;
//+ (TextFieldValidator *) WeightValidator;
+ (TextFieldValidator *) EmailValidator;
+ (TextFieldValidator *) NumValidator;
//+ (TextFieldValidator *) EmptyValidator;
+ (TextFieldValidator *) DoNoThingValidator;
+ (TextFieldValidator *) QQValidator;
- (BOOL) validateTextField:(UITextField *)textField erro:(NSString **)erroMsg;
- (BOOL) validateString:(NSString *)str erro:(NSString **)erroMsg;

@end
