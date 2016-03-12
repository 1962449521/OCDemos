//
//  main.m
//  SharePhoto
//
//  Created by 胡 帅 on 14-7-22.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "SBJsonParser.h"
#import "ASIDataDecompressor.h"
#import "ASIDataCompressor.h"




void testAPI(int testNum)
{
    NetAccess *netAccess = [[NetAccess alloc]init];
    id result;
    //1.TEST SERVERTIME
    if(testNum == 0){
        HSLog(@"test serverTime");
        result = [netAccess getServerTimestamp];
        HSLog(@"%@", result);
    }
    //2.TEST REGISTER
    if (testNum == 1) {
        NSString *userStr = @"tesths001";
        NSString *pwdStr = @"tesths";
        NSString *encodePassword = [Coordinator encodePassword:pwdStr userName:userStr];
        if (![MemberManager validateUserInputUserName:userStr password:pwdStr]) {
            POPUPINFO(@"用户名或密码不符合要求");
            return ;
        }
        NSNumber *gender = @1;
        HSLog(@"test Register");
        UserProfile *baseUserProfile = [[UserProfile alloc]init];
        [baseUserProfile assignValue:@{@"name":userStr, @"password":encodePassword, @"gender":gender}];

        BaseVC *vc = [[BaseVC alloc]init];
        [MemberManager registerUserWithUserProfile:baseUserProfile atVC:vc];
        while (1) {
            
        }
    }
    // 3.Test Login
    if (testNum == 2) {
        NSString *userStr = @"test2206";
        NSString *pwdStr = @"test2206";
        NSString *encodePassword = [Coordinator encodePassword:pwdStr userName:userStr];
        if (![MemberManager validateUserInputUserName:userStr password:pwdStr]) {
            POPUPINFO(@"用户名或密码不符合要求");
            return ;
        }
        NSNumber *gender = @2;
        HSLog(@"test Login");
        UserProfile *baseUserProfile = [[UserProfile alloc]init];
        [baseUserProfile assignValue:@{@"name":userStr, @"password":encodePassword, @"gender":gender}];
        
        BaseVC *vc = [[BaseVC alloc]init];
        [MemberManager loginUserWithUserProfile:baseUserProfile atVC:vc];
        while (1) {
            
        }
    }
    // 4. Test Compress
    if (testNum == 3) {
        NSString *plainText = @"{\"gender\":0,\"lastRefreshTime\":1411372548,\"latitude\":75.89,\"longitude\":25.89,\"pager\":{\"first\":true,\"last\":false,\"offset\":0,\"pageCount\":0,\"pageNumber\":1,\"pageSize\":20,\"recordCount\":0},\"result\":{\"success\":true},\"signature\":{\"nonce\":4085282300,\"sign\":\"MjZBQUU2NkYwRTJDQzU3QjQwMzM0ODkwNzFDQzVDQ0QyOUQyQjM5Qw==\",\"timestamp\":1411659631,\"userId\":3},\"type\":1,\"userId\":3}";
        NSString *aesKey = [Coordinator key:@"1411659631"];
        NSString *giv = [@"646253d202202068" base64String];
        NSLog(@"aesKey:%@, giv:%@", aesKey, giv);
        NSString *postBodyJson = [Coordinator AES128Encrypt:plainText key:aesKey Iv:giv];
        NSLog(@"encrptTest:%@", postBodyJson);
        
        
        postBodyJson = @"a5KWKFbmNz1nI0aytmupKExgmtXYnIiDFYUn/bmXywJP533JO8BSQ1xyBeIo3IwbuoGnixaJNYobYfXmgLXhEKi6S5Ozjdz3Gn2/5usdvmoJWE//U27F6V9Un2n5ZDPw2kl/ucTqNRDIT5NrbGS0P32S8lg4l0wIdXJSd5GZawY6kY4h3NDwmLYmtMBdQauupfNluh49AndQOdvjTJxQAG7ZoofpXuHAt+DowVpoA+jX9kayy/HOnq/UvkNfp/Tx6amH8Cz67QmS+niXLCbYUzwkuH6iGV9GRApLt+m59ccbGWUrb87xVnPyHwpTefRs";
        
        
        NSData *unCompressedPostBody = [NSMutableData dataWithData:[postBodyJson dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"unCompressedPostBodybytes:%@",[unCompressedPostBody base64String]);
        [[[NetAccess alloc]init] PrintNSData:unCompressedPostBody];
        
        NSData *compressedPostBody = [ASIDataCompressor compressData:unCompressedPostBody error:nil];
        [[[NetAccess alloc]init] PrintNSData:compressedPostBody];
    }

    
}

int main(int argc, char * argv[])
{
    
    @autoreleasepool {
        
        
        int testNum = 9999;
        testAPI(testNum);
        if(testNum == 9999)
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        
    }
}
