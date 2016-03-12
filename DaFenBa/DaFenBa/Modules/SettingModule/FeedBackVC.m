//
//  FeedBackVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-2.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//


// MARK: 如需测试接口 请设置如下宏

#define isMOCKDATADebugger NO
#define SLEEP //sleep(1.5)

#import "FeedBackVC.h"

@interface FeedBackVC ()<UITextViewDelegate>

@end

static const int maxCharacterNum = 300;

@implementation FeedBackVC
{
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"反馈意见"];
    self.isNeedBackBTN = YES;
    self.isNeedHideBack = YES;
    CGRect frame = CGRectMake(15, 5, 40, 34);
    UIColor *textColor = ColorRGB(244.0, 149.0, 42.0);
    RIGHT_TITLE(frame, @"发送", textColor, nil, sendFeedBack:);
//    BACK_TITLE(frame, @"取消", textColor, nil, backToPreVC:);
    _textView.delegate = self;
    _textView.layer.borderColor = [[UIColor grayColor]CGColor];
    _textView.layer.borderWidth = 1.0f;
    _textView.returnKeyType = UIReturnKeySend;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {

    NSInteger number = [textView.text length];
    if (number > maxCharacterNum) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"字符个数不能大于%d",maxCharacterNum] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        textView.text = [textView.text substringToIndex:maxCharacterNum];
        number = maxCharacterNum;
    }
    // self.statusLabel.text = [NSString stringWithFormat:@"%d/128",number];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self sendFeedBack:nil];
        return NO;
    }
    
    return YES;
}
- (void)sendFeedBack:(id)sender
{
    /*
     . FeedbackModule
     * add: POST
     ** request: {feedback: {content: feedback content, email: feedback email, userId: login user id}}
     ** {result: {success: true, msg: error message}}

     */

    [_textView resignFirstResponder];
    NSString *str = _textView.text;
    if([[str stringByReplacingOccurrencesOfString:@" " withString:@"'"]length] == 0 )
    {
        POPUPINFO(@"请先填写反馈意见");
        return;
    }

    
    [self startAview];
    
    NSString *email = STRING_judge([Coordinator userProfile].email);
    NSNumber *userId = [Coordinator userProfile].userId;
    NSString *content = STRING_joint(@"@打分吧iPhone客户端#", _textView.text);
    NSDictionary *para = @{@"feedback": @{@"content": content, @"email": email, @"userId": userId}};
if(isMOCKDATADebugger)
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SLEEP;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dic = @{@"result": @{@"success": @YES, @"msg": @""}};
            [self receivedObject:dic withRequestId:FeedbackModule_add_tag];
        });
    });
    return;

}
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic = [self.netAccess passUrl:FeedbackModule_add andParaDic:para withMethod:FeedbackModule_add_method andRequestId:FeedbackModule_add_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {
                POPUPINFO(@"反馈意见发送成功！");
            }
            else
               POPUPINFO(@"反馈意见发送失败！");

        });
    });
    
}
#pragma mark - AsynNetAccessDelegate


- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    [self stopAview];
    NSDictionary *dic;
    if (!TYPE_isDictionary(receiveObject))
    {
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
        
        return;
    }
    else
    {
        dic = (NSDictionary *)receiveObject;
    }
    
    NSDictionary *result = dic[@"result"];
    if (!NETACCESS_Success)
    {
        POPUPINFO(@"发送失败");
        return;
    }
    else
    {
        POPUPINFO(@"发送成功");
        return;

    }
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    
    [self stopAview];
    
    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
}

@end
