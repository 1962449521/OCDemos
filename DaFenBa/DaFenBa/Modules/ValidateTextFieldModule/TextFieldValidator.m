//
//  TextFieldValidator.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-9.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "TextFieldValidator.h"

@implementation TextFieldValidator

+ (TextFieldValidator *)DoNoThingValidator
{
    TextFieldValidator *validator = [[TextFieldValidator alloc]init];
    validator.pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[\\s\\S]*$"];
    validator.erroMsg = @"这都能匹配不了吗";
    return validator;

}

+ (TextFieldValidator *) EmailValidator
{
    TextFieldValidator *validator = [[TextFieldValidator alloc]init];
    validator.pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[\\w!#$%&'*+/=?^_`{|}~-]+(?:\\.[\\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\\w](?:[\\w-]*[\\w])?\\.)+[\\w](?:[\\w-]*[\\w])?$"];
    validator.erroMsg = @"邮件地址不正确";
    return validator;
}
+ (TextFieldValidator *) QQValidator
{
    TextFieldValidator *validator = [[TextFieldValidator alloc]init];
    validator.pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[1-9][0-9]{4,}$"];
    validator.erroMsg = @"QQ号码不正确";
    return validator;
}
+ (TextFieldValidator *) NumValidator
{
    TextFieldValidator *validator = [[TextFieldValidator alloc]init];
    validator.pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[0-9]+([.]{1}[0-9]{1,10})?$"];
    validator.erroMsg = @"该输数字的地方要输数字哦";
    return validator;
}
- (BOOL)validateTextField:(UITextField *)textField erro:(NSString *__autoreleasing *)erroMsg
{
    if(![self.pred evaluateWithObject:textField.text])
    {
        UILabel *label = [[UILabel alloc]initWithFrame:textField.frame];
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:11];
        [textField.superview addSubview:label];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [label removeFromSuperview];
        });
        return NO;
    }
    else
        return YES;
        
}
- (BOOL) validateString:(NSString *)str erro:(NSString **)erroMsg
{
    if (str==nil || [str stringByReplacingOccurrencesOfString:@" " withString:@""]) {
        return YES;
    }
    str = STRING_fromId(str);
    if(![self.pred evaluateWithObject:str])
    {
        *erroMsg = self.erroMsg;
        return NO;
    }
    else
        return YES;

}
@end
