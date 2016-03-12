//
//  DetailUserVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-31.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//
//备忘：0-99为本页常态控件用tag, 100-199为pickerView用，200-299为附加uicontrol用

#define excludeRow i==1 || i==2 || i==3 || i==6 //非textfield输入的列表项
#define bigFiled i == 3  //自定义输入编辑框
static NSInteger maxTextFieldLength = 50;//textfield的最大字长

#import "MeProfileDetailVC.h"
#import "PickerVC.h"
#import "BigFieldVC.h"
#import "UpYun.h"
#import "TextFieldValidator.h"

#import "UIImage+scale.h"
#import "UIImage+fixOrientation.h"





@interface MeProfileDetailVC ()<UITextFieldDelegate, pickerUserDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property NSMutableArray *valueArray;

@end

@implementation MeProfileDetailVC
{
    int keyboardHeight;
    BOOL keyboardIsShowing;
    __block BOOL isUpYunSuccess;
    __block BOOL isUpYunFinished;
    __block NSString *avatarUrl;
    
    NSCondition *upYunCondition;
    
    NSArray *txtArr;
}

@synthesize userName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        upYunCondition = [[NSCondition alloc]init];
        _valueArray = [NSMutableArray arrayWithCapacity:0];
        
    }
    return self;
}

/**
 *	@brief	绘制背景
 */
- (void)drawBg
{
    [self.scrollView setContentSize:CGSizeMake(DEVICE_screenWidth, self.bg3.bottom +10.0)];
    
    //设置背景
    [self.view setBackgroundColor:ThemeBGColor_gray];
    [self.bg1 setImage:areaBgImage];
    [self.bg2 setImage:areaBgImage];
    [self.bg3 setImage:areaBgImage];
    [self.bg4 setImage:areaBgImage];
    
    
    
    for (int i = 1; i < 9; i ++) {
        UIImageView *seperatorLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_screenWidth, 3)];
        seperatorLine.contentMode = UIViewContentModeScaleToFill;
        [seperatorLine setImage:[UIImage imageNamed:@"seperatorLine218h"]];
//        UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_screenWidth, 1)];
        
        if (i < 4) {
            [seperatorLine setY:self.bg2.top + 44 * i -1 ];
        }
        else if(i < 5)
            [seperatorLine setY:self.bg4.top + 44 * (i-3) -1 ];
        else
            [seperatorLine setY:self.bg3.top + 44 * (i-4) -1 ];
        [self.scrollView addSubview:seperatorLine];
        
    }

}
/**
 *	@brief	绘制控件
 */
- (void)drawViews

{
    //列表项
    NSMutableArray *txtMutableArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *cellTitles = @[@"昵称", @"性别", @"所在地", @"简介", @"身高",@"体重" , @"生日", @"邮箱", @"微信", @"QQ", @"微博"];
    _valueArray = [[NSMutableArray alloc]initWithArray:cellTitles];
    NSArray *promptStrs = @[@"输入昵称", @"输入性别", @"输入所在地", @"输入简介", @"你的身高是？",@"你的体重是？", @"输入生日", @"输入邮箱",@"输入微信", @"输入QQ",  @"输入微博"];
    NSArray *keyBoardTypes = @[ NUMBER(UIKeyboardTypeDefault),
                               NUMBER(UIKeyboardTypeDefault),
                               NUMBER(UIKeyboardTypeDefault),
                                NUMBER(UIKeyboardTypeDefault),
                                NUMBER(UIKeyboardTypeNumbersAndPunctuation),
                                NUMBER(UIKeyboardTypeNumbersAndPunctuation),
                               NUMBER(UIKeyboardTypeDefault),
                               NUMBER(UIKeyboardTypeEmailAddress),
                               NUMBER(UIKeyboardTypeDefault),
                               NUMBER(UIKeyboardTypeNumbersAndPunctuation),
                                NUMBER(UIKeyboardTypeDefault)];
    UITextField *txt;
    UIButton *tapcontrol ;
    for (int i = 0; i< [cellTitles count]; i++) {
        NSString *str = cellTitles[i];
        UILabel *label = [[UILabel alloc]init];
        label.text = str;
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = ColorRGB(162.0, 162.0, 162.0);
        [label sizeToFit];
        [label setX:20.0];
        
        txt = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, 150, 44)];
        
        if (i<4) {
            [label setCenter:CGPointMake(label.center.x, self.bg2.top + 44 * i +22)];
        }
        else if(i<6)
            [label setCenter:CGPointMake(label.center.x, self.bg4.top + 44 * (i - 4) + 22)];
        else
            [label setCenter:CGPointMake(label.center.x, self.bg3.top + 44 * (i - 6) + 22)];
        //[txt setHeight:label.height];
        [txt setCenter:CGPointMake(txt.center.x, label.center.y)];
        txt.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //txt.backgroundColor = [UIColor redColor];
        txt.tag = i;
        txt.placeholder = promptStrs[i];
        if (!(excludeRow)) {
            txt.delegate = self;
            txt.returnKeyType =  UIReturnKeyNext;
            txt.keyboardType = [keyBoardTypes[i] intValue];
        }
        else
        {
            txt.userInteractionEnabled = NO;
            tapcontrol = [[UIButton alloc]initWithFrame:txt.frame];
            tapcontrol.tag = txt.tag + 200;
            
            [tapcontrol setBackgroundColor:[UIColor clearColor]];
            [tapcontrol addTarget:self action:@selector(tapDown:) forControlEvents:UIControlEventTouchDown];
            [self.scrollView addSubview:tapcontrol];
        }
        if (i == 0) {//用户名不可改
            txt.userInteractionEnabled = NO;
            txt.textColor =  ColorRGB(162.0, 162.0, 162.0);
        }
        if (false){//(self.visitorType == FromGuest) {//外人访问
            if(txt)txt.userInteractionEnabled = NO;
            if(tapcontrol)tapcontrol.userInteractionEnabled = NO;
        }
        [self.scrollView addSubview:label];
        [self.scrollView addSubview:txt];
        
        [txt addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        [txtMutableArr addObject: txt];
    }
    txt.returnKeyType =  UIReturnKeyDone;
    txtArr = [NSArray arrayWithArray:txtMutableArr];
    
}

/**
 *	@brief	拾取器、长文本编辑器
 */
- (void)initPickerVCs{

    //可重用的pickerViewController
    PickerVC *pickerVC = [[PickerVC alloc]init];
    pickerVC.userDelegate = self;
    [self addChildViewController:pickerVC];
    
    
    BigFieldVC *descriptionVC = [[BigFieldVC alloc]init];
    descriptionVC.userDelegate = self;
    descriptionVC.titlestr = @"简介";
    descriptionVC.id = 3;
    [self addChildViewController:descriptionVC];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIViewController *vc in self.childViewControllers) {
            if (vc.view != nil) {
                [self.view addSubview:vc.view];
            }
        }
    });
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //getdata 获取用户详细资料
    [self assignValueForControls];
    
}
 - (void)assignValueForControls
{//@[@"昵称", @"性别", @"所在地", @"简介", @"身高",@"体重" , @"生日", @"邮箱", @"微信", @"QQ", @"微博"];
    UserProfile *userProfile = [Coordinator userProfile];
    NSArray *arr = @[STRING_judge( userProfile.avatar),
                     STRING_judge(userProfile.srcName),//[[MemberManager shareInstance]infoCenter][@"userName"],
                     [userProfile.gender intValue] == 1 ? @"男" : @"女",
                     STRING_judge(userProfile.address),
                     STRING_judge(userProfile.intro),//[[MemberManager shareInstance]infoCenter][@"intro"],
                     userProfile.tall,
                     userProfile.weight,
                     STRING_judge(userProfile.birthday),
                     STRING_judge(userProfile.email),
                     STRING_judge(userProfile.weixin),
                     userProfile.qq,
                     STRING_judge(userProfile.weibo)
                    ];
    _valueArray = [NSMutableArray arrayWithArray:arr];
    
    for (int index = 0; index < [_valueArray count]; index++) {
        if (index == 0) {
            [self.headIcon setAvartar:_valueArray[0]];
        }
        else
        {
            UITextField *txt =  txtArr[index - 1];
            NSString *str = STRING_fromId(_valueArray[index]);
            txt.text = [str isEqualToString:@"0"] ? @"" : str ;
        }
    }
    
}
/**
 *	@brief	初始视图及控件
 */
- (void)configSubViews

{
    [self drawBg];
    [self drawViews];
    self.isNeedHideTabBar = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self initPickerVCs];
    });
    [self setNavTitle:@"编辑资料"];
    CGRect frame = CGRectMake(20, 5, 40, 34);
    UIColor *textColor = ColorRGB(244.0, 149.0, 42.0);
    RIGHT_TITLE(frame, @"完成", textColor, nil, editFinished);
    
    self.isNeedBackBTN = YES;
    
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tapBG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.scrollView addGestureRecognizer:tapBG];
    
    if (true){//self.visitorType == FromOwner) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(modifyHeadicon:)];
        self.bg1.userInteractionEnabled = YES;
        [self.bg1 addGestureRecognizer:tap];
    }
    

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 拾取器

/**
 *	@brief	触发拾取器
 *
 *	@param 	sender 	<#sender description#>
 */
- (void) tapDown:(UIControl *)sender
{
    [self hideKeyBoard];
    if (sender.bottom > DEVICE_screenHeight - 64 - 260) {
        float y = sender.bottom - (DEVICE_screenHeight - 64 - 260);
        [UIView beginAnimations:nil context:nil];
        _scrollView.contentSize = CGSizeMake(DEVICE_screenWidth , DEVICE_screenHeight + 260 );
        _scrollView.contentOffset = CGPointMake(0, y);
        [UIView commitAnimations];
    }
    int tag = sender.tag - 201;

    NSArray *pickerArr = self.childViewControllers;
    UIViewController<pickerVCDelegate> *vc;
    UITextField *txt = (UITextField *)[self.view viewWithTag:tag + 1];

    //性别，所在地，简介，生日
    NSArray *titleArr = @[@"性别", @"所在地", @"简介",@"",@"", @"生日"];
    NSArray *types = @[NUMBER(typeSinglepicker), NUMBER(typeLocationPicker), @9999,@9999,@9999, NUMBER(typeDataPicker)];
    switch (tag) {
        case 0:
            vc = pickerArr[0];
            break;
        case 1:
            vc = pickerArr[0];
            break;
        case 2:
            vc = pickerArr[1];
            break;
        case 5:
            vc = pickerArr[0];
            break;
        default:
            break;
    }
    [vc setId:tag+1];//id与相同TAG的文本框一致
    [vc setTitlestr:titleArr[tag]];
    
    [vc setIsNeedGotoNext:NO];

    if ([vc isKindOfClass:[PickerVC class]]) {
        ((PickerVC *)vc).pickerType = [types[tag] intValue];
        if (((PickerVC *)vc).pickerType == typeSinglepicker) {
            ((PickerVC *)vc).singleSource = @[@"男", @"女"];
        }
        [(PickerVC *)vc reNewControl];
    }
    [vc setValue:txt.text];
    [vc show];
}
    

/**
 *	@brief	拾取完成 代理机制
 *
 *	@param 	value
 *	@param 	sender
 */
- (void)pickerFinishedWithValue:(NSString *)value From:(id)sender
{
    if (![sender conformsToProtocol:@protocol(pickerVCDelegate)]) {
        return;
    }
    UIViewController<pickerVCDelegate> *vc = sender;

    [UIView beginAnimations:nil context:nil];
    _scrollView.contentSize = CGSizeMake(DEVICE_screenWidth, 534);
    _scrollView.contentOffset = CGPointMake(0, 0);
    [UIView commitAnimations];
    
    int i = vc.id;
    UITextField *txt = (UITextField *) [self.view viewWithTag:i];
    txt.text = value;
    i++;
    if(!vc.isNeedGotoNext)//未点击下一项
    {
        [self hidePickers];
        return;
    }
    if(excludeRow) {
        //[self hideKeyBoard];
        UIControl *control = (UIControl *)[self.view viewWithTag:i+200];
        [self tapDown:control];
    }
    else
    {
        txt = (UITextField *) [self.view viewWithTag:i];
        [txt becomeFirstResponder];
    }
}

/**
 *	@brief	拾取取消
 *
 *	@param 	sender 	<#sender description#>
 */
- (void)pickerCancelFrom:(id)sender
{
    [self hideKeyBoard];
}
/**
 *	@brief	隐藏所有拾取器
 */
- (void)hidePickers
{
    for (UIViewController *pickerVC in self.childViewControllers) {
        if ([pickerVC respondsToSelector:@selector(hide)]) {
            [pickerVC performSelector:@selector(hide) withObject:nil];
        }
    }
}


#pragma mark -  UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hidePickers];
    //让整个界面提高 使编辑的textfield不被键盘摭住
    if (textField.bottom > DEVICE_screenHeight - 64 - 260) {
        float y = textField.bottom - (DEVICE_screenHeight - 64 - 260);
        [UIView beginAnimations:nil context:nil];
        _scrollView.contentSize = CGSizeMake(DEVICE_screenWidth , DEVICE_screenHeight + 260 );
        _scrollView.contentOffset = CGPointMake(0, y);
         [UIView commitAnimations];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDone) {
        [self hideKeyBoard];
    }
    else
    {
        int i = textField.tag + 1;
        if(excludeRow) {
            [self hideKeyBoard];
            UIControl *control = (UIControl *)[self.view viewWithTag:i+200];
            [self tapDown:control];
        }
        else
        {
            UITextField *txt = (UITextField *) [self.view viewWithTag:i];
            [txt becomeFirstResponder];
        }
    }
    return YES;
}
- (void)hideKeyBoard
{
    [super hideKeyBoard];
    [self hidePickers];
    [UIView beginAnimations:nil context:nil];
    _scrollView.contentSize = CGSizeMake(DEVICE_screenWidth, 534);
       // _scrollView.contentOffset = CGPointMake(0, 0);
    [UIView commitAnimations];
    
    

}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return range.location >= maxTextFieldLength ? NO : YES;
    return YES;
}
#pragma  mark - 修改头像
- (IBAction)modifyHeadicon:(id)sender
{
    UIImagePickerController *pickerImageVC = [[UIImagePickerController alloc]init];
    pickerImageVC.allowsEditing = YES;
    pickerImageVC.delegate = self;

    [APPDELEGATE.mainVC presentViewController:pickerImageVC animated:YES completion:nil];
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    image = [image fixOrientation];
    image = [image scaleTo:CGSizeMake(120.0, 120.0)];
    //[self.headIcon setImage:image];
    
    UpYun *uy = [[UpYun alloc]init];
    uy.successBlocker = ^(id data)
    {
        isUpYunSuccess = YES;
        avatarUrl = [[data[@"url"] componentsSeparatedByString:@"/"]lastObject];
        [self.headIcon setAvartar:avatarUrl];
        [_valueArray replaceObjectAtIndex:0 withObject:avatarUrl];
        [upYunCondition lock];
        isUpYunFinished = YES;
        [upYunCondition signal];
        [upYunCondition unlock];
        POPUPINFO(@"上传头像成功");
    };
    uy.failBlocker = ^(NSError * error)
    {
        isUpYunSuccess = NO;
        [upYunCondition lock];
        isUpYunFinished = YES;
        [upYunCondition signal];
        [upYunCondition unlock];
        POPUPINFO(@"上传头像失败");
          NSLog(@"UpYunErro%@",error);
    };
    uy.progressBlocker = ^(CGFloat percent, long long requestDidSendBytes)
    {
        //[_pv setProgress:percent];
    };
    
    [uy uploadImage:image savekey:[UpYun getSaveKey:@"avatar"]];
    
    
    [APPDELEGATE.mainVC dismissViewControllerAnimated:YES completion:nil];
    //[self cropImage:image];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [APPDELEGATE.mainVC dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 提交编辑内容
- (void)editFinished
{
    [self hideKeyBoard];
    if(![self validInput])return;
    else
    {
        NSNumber *userId = [Coordinator userProfile].userId;
        NSDictionary *para =
                    @{@"userId"     : userId,
                      @"gender" : ([_valueArray[2] isEqualToString:@"男" ]? @1 : @2),
                      @"avatar" : _valueArray[0],//componentsSeparatedByString:@"."][0],
                      @"address" : _valueArray[3],
                      @"intro"  : _valueArray[4],
                      @"tall"   : _valueArray[5],
                      @"weight" : _valueArray[6],
                      @"email"  : _valueArray[8],
                      @"weixin" : _valueArray[9],
                      @"qq"     : _valueArray[10],
                      @"weibo"  : _valueArray[11],
                      @"birthday" : _valueArray[7],
                      };
        UserProfile *updateUserProfile = [UserProfile new];
        [updateUserProfile assignValue:para];
        [Coordinator updateUserProfile:updateUserProfile atVC:self];
    }
    
    //POPUPINFO(@"valid and submit");
}
- (BOOL)validInput
{
    BOOL result = YES;
    NSArray *validators = @[[TextFieldValidator DoNoThingValidator],
                            [TextFieldValidator DoNoThingValidator],
                            [TextFieldValidator DoNoThingValidator],
                            [TextFieldValidator DoNoThingValidator],
                            [TextFieldValidator DoNoThingValidator],
                            [TextFieldValidator NumValidator],
                            [TextFieldValidator NumValidator],
                            [TextFieldValidator DoNoThingValidator],
                            [TextFieldValidator EmailValidator],
                            [TextFieldValidator DoNoThingValidator],
                            [TextFieldValidator QQValidator],
                            [TextFieldValidator DoNoThingValidator]
                            
                            ];
    NSString *erro = @"";
    for (int index = 0; index < [_valueArray count]; index++) {
        TextFieldValidator *validator = (TextFieldValidator *)(validators[index]);
        result = [validator validateString:STRING_fromId(_valueArray[index]) erro:&erro];
        if(!result){break;}
        if (index == 5 || index ==6 || index == 10) {
            NSString *value = _valueArray[index];
            NSNumber *numValue = [NSNumber numberWithLongLong:[value longLongValue]];
            [_valueArray replaceObjectAtIndex:index withObject:numValue];
            
        }
    }
    if (!result) {
        POPUPINFO(erro);
        return NO;
    }

    return YES;
}
#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]) {
        id newValue = [change valueForKey:NSKeyValueChangeNewKey];
        int index = [(UITextField *)object tag];
        
        if (index < _valueArray.count)
            [_valueArray replaceObjectAtIndex:index+1 withObject:newValue];
    }
}

@end
