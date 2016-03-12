//
//  DefineMethod.h
//
//  Created by Hushuai on 14-5-9.
//  Copyright (c) 2014年 Hushuai. All rights reserved.
//
/****************************************************
 * Module name:   DefineMethod.h
 * Author//Date:  胡帅/14-05-09
 * Version:      1.0  //版本
 * Description:  常用
 
 ------------------------------------------------------
 *****************************************************/
/*协议*/
//#define isUseMockData
#define ACCESSFAILEDMESSAGE @"请检查网络或报告打分吧IOS攻城狮"
@protocol LoginDelegate <NSObject>
@optional
- (void) LoginSuccessful:(id)message;
- (void) LoginFail:(id)message;
- (void) LoginCancel:(id)message;
@end
@protocol pickerUserDelegate <NSObject>
@optional
- (void)pickerFinishedWithValue:(NSString *)value From:(id)sender;
- (void)pickerCancelFrom:(id)sender;
- (UIView *)view;
@end
@protocol pickerVCDelegate <NSObject>

- (NSUInteger)id;
- (BOOL)isNeedGotoNext;
- (void)setTitlestr:(NSString *)str;
- (void)setId:(NSUInteger)id;
- (void)setValue:(NSString *)value;
- (void)setIsNeedGotoNext:(BOOL)isNeedGotoNext;
- (void)show;
- (void)hide;

@end
/*-----------通用的头文件------------------------------*/
#import "LPPopup.h"
#import "Reachability.h"
#import "UIView+frame.h"
#import "UIViewExt.h"



/*----------------------本项目self头文件及方法-------------------*/
#import "NetAccessAPI.h"
#import "BaseVC.h"
#import "BaseObject.h"
#import "BaseCell.h"
#import "ConcreteMainVC.h"

#import "UIImageView+DaFenBa.h"

#import "UIImageView+Layer.h"
#import "BMapKit.h"
#import "MemberManager.h"
#import "ScoreManager.h"
#import "GalleryManager.h"
#import "MessageManager.h"
#import "ShareManager.h"
#import "LastRefreshTime.h"
#import "PostManager.h"


#import "Coordinator.h"


#import "AppDelegate.h"

#define ThemeBGColor ColorRGB(255.0, 255.0, 255.0)
#define ThemeBGColor_gray ColorRGB(248.0, 248.0, 248.0)
#define TheMeBorderColor ColorRGB(237.0, 237.0, 237.0)
#define fladeTime 3.0
//刷新view的高度
#define refreshViewHeight 60.0

#define kDuration 0.3
#define headToTopHeight 20
#define textGrayColor ColorRGB(119.0, 119.0, 119.0)
#define areaBgImage [[UIImage imageNamed:@"areaBg"]stretchableImageWithLeftCapWidth:5 topCapHeight:5]
//#define UIViewBeginAnimation [UIView beginAnimations:nil context:nil];\
//[UIView setAnimationBeginsFromCurrentState:YES];\
//[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];\
//[UIView setAnimationDelegate:self];\
//[UIView setAnimationDuration:kDuration]

#define UIViewBeginAnimation(i) [UIView beginAnimations:nil context:nil];\
[UIView setAnimationBeginsFromCurrentState:YES];\
[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];\
[UIView setAnimationDelegate:self];\
[UIView setAnimationDuration:(i)]


#define NUMBER(i) [NSNumber numberWithInt:(i)]

/*-----------0.调试类--------------------------------*/

#define THIS_FILE [[NSString stringWithUTF8String:__FILE__] lastPathComponent]
#define THIS_METHOD NSStringFromSelector(_cmd)

#define HSDescriptionForCurrentTime()\
({ NSDateFormatter* formatter = [[NSDateFormatter alloc] init];\
[formatter setDateFormat:@"HH:mm:ss"];\
NSDate *date = [NSDate date];\
NSString *str = [formatter stringFromDate:date];\
const char * a =[str UTF8String];\
a;\
})
#if 1
#define HSLog(FORMAT, ...) \
printf("[%s] %s\n", HSDescriptionForCurrentTime(), [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#define HSLogTrace() HSLog(@"[TRACING] FILE: %@ >> METHOD: %@ >> LINE: %d", THIS_FILE, THIS_METHOD, __LINE__)
#define HSLogError(FORMAT, ...)

#else

#define HSLog(...)
#define HSLogTrace()
#define HSLogError(FORMAT, ...)

#endif

/*-----------1.设备类---------------------------------*/
#define StatusHeight ((DEVICE_versionAfter7_0)?0:20)
#define DEVICE_screenHeight [[UIScreen mainScreen] bounds].size.height//屏幕高度 返回：float
#define DEVICE_screenWidth  [[UIScreen mainScreen] bounds].size.width //屏幕宽度 返回：float
#define DEVICE_versionAfter7_0 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) //系统版本高于7.0 返回：BOOL
#define DEVICE_isiPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)//判断是否是iPhone5 返回：BOOL
/*-----------2.网络类---------------------------------*/
#define NETWORK_isReachable [[Reachability reachabilityForInternetConnection] isReachable]//需要导入Reachablity.m,判断是否可联至互联网 返回：BOOL


/*-----------3.数据类型类---------------------------------*/
#define TYPE_isDictionary(object) (object && [object isKindOfClass: [NSDictionary class]])//判断是否为字典类型 返回：BOOL
#define TYPE_isArray(object) (object && [object isKindOfClass: [NSArray class]])//判断是否为数组类型 返回：BOOL
#define TYPE_isString(object) (object && [object isKindOfClass: [NSString class]])//判断是否为字符串类型 返回：BOOL

/*-----------4.系统对象类---------------------------------*/
#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication]delegate])//获得当前程序代理实例 返回: id
#define USERDEFAULT_get(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]//从本地存储中读取数据 返回：id
#define USERDEFAULT_set(object,key)\
[[NSUserDefaults standardUserDefaults] setObject:object forKey:key];//将数据存入本地 返回：无
#define USERDEFAULT_syn [[NSUserDefaults standardUserDefaults]synchronize]//同步
#define USERDEFAULT_remove(key)\
[[NSUserDefaults standardUserDefaults]removeObjectForKey:key];\
[[NSUserDefaults standardUserDefaults]synchronize];


/*-----------4.数据处理类---------------------------------*/
//----时间字符串转时间戳---
#define DataStr2Timestamp(dateStr,format)\
NSDateFormatter* formatter = [[NSDateFormatter alloc] init];\
[formatter setDateFormat:format];\
NSDate *dateP = [formatter dateFromString:dateStr];\
dateStr = [NSString stringWithFormat:@"%ld", (long)[dateP timeIntervalSince1970]]

//----时间戳转字符串----
#define TimeStamp2NSDataStr(dateStr,format)\
NSDateFormatter* formatter = [[NSDateFormatter alloc] init];\
[formatter setDateFormat:format];\
NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateStr.longLongValue];\
dateStr = [formatter stringFromDate:date]

#define STRING_fromInt(i) [NSString stringWithFormat:@"%d", i]
#define STRING_fromId(i) [NSString stringWithFormat:@"%@", i]

#define STRING_isEqual(str1, str2) [str1 isEqualToString:str2]//判断字符串是否相等 返回：BOOL
#define STRING_judge(str) (!(str == nil || [str isKindOfClass:[NSNull class]] )?str:@"")//判断字符串变量是否为nil 返回: NSString
#define STRING_joint(str1, str2) [NSString stringWithFormat:@"%@%@", str1, str2]
#define URL(str)[NSURL URLWithString:str]//字符串转URL
#define UTF8_decode(str) [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]//utf8解码 返回：NSString
#define UTF8_encode(str) [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]//utf8编码 返回：NSString

/*-----------5.视图显示类---------------------------------*/
#define POPUPINFO(infotxt) [LPPopup popupCustomText:infotxt]//弹出提示信息，并自动隐藏，单例
#define ColorRGB(r,g,b) [UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:1.00]
//自定义左键
#define BACK_TITLE(frame, title, textcolor, imagestr, method) \
UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];\
UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];\
leftBtn.frame = CGRectMake(0, 0, 60, 44);\
leftBtn.imageEdgeInsets = UIEdgeInsetsMake(frame.origin.y, frame.origin.x, 44 - frame.origin.y - frame.size.height, 60 - frame.origin.x - frame.size.width);\
if(textcolor != nil)\
[leftBtn setTitleColor:textcolor forState:UIControlStateNormal];\
[leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];\
[leftBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];\
if(title != nil)\
[leftBtn setTitle:title forState:UIControlStateNormal];\
if (imagestr != nil)\
[leftBtn setImage: [UIImage imageNamed:imagestr] forState:UIControlStateNormal];\
[leftBtn setImage: [UIImage imageNamed:@"transculent"] forState:UIControlStateHighlighted];\
[leftBtn addTarget:self action:@selector(method) forControlEvents:UIControlEventTouchUpInside];\
[leftView addSubview:leftBtn];\
UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];\
self.navigationItem.leftBarButtonItem = leftItem
//定义右键，输入参数为按钮的图片和方法
#define RIGHT_TITLE(frame, title, textcolor, imagestr, method)\
UIView *rightBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];\
UIButton *callBtn = [UIButton buttonWithType:UIButtonTypeCustom];\
callBtn.frame = CGRectMake(0, 0, 60, 44);\
UIEdgeInsets edgeInsets = UIEdgeInsetsMake(frame.origin.y, frame.origin.x, 44 - frame.origin.y - frame.size.height, 60 - frame.origin.x - frame.size.width);\
if(textcolor != nil)\
[callBtn setTitleColor:textcolor forState:UIControlStateNormal];\
[callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];\
[callBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];\
if(title != nil)\
[callBtn setTitle:title forState:UIControlStateNormal];\
[callBtn addTarget:self action:@selector(method) forControlEvents:UIControlEventTouchUpInside];\
if (imagestr != nil){\
[callBtn setImage: [UIImage imageNamed:imagestr] forState:UIControlStateNormal];\
callBtn.imageEdgeInsets = edgeInsets;\
}\
else callBtn.titleEdgeInsets = edgeInsets;\
[callBtn setBackgroundImage: [UIImage imageNamed:@"transculent"] forState:UIControlStateHighlighted];\
[rightBarView addSubview:callBtn];\
UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rightBarView];\
self.navigationItem.rightBarButtonItem = rightBtn

