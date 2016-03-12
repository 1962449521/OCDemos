//
//  PostManager.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-21.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

typedef NS_ENUM(NSUInteger, TypeUploadPhotoSource)
{
    TypeCamera,
    TypeAlbum
};
#import "PostManager.h"
#import "PostProfile.h"
#import "PhotoUploadVC.h"
#import "PhotoUpLoadSuccessVC.h"
#import "UpYun.h"
#import "DaFenBaOpenUDID.h"
#import "HomeVC.h"
#import "UIImage+fixOrientation.h"



@interface PostManager ()<PhotoUploadDelegate, AsynNetAccessDelegate,UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,PhotoUploadDelegate>

@end

@implementation PostManager
{
     UIImagePickerController *pickerImageVC;
}

+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static PostManager* instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
        instance.postProfile = [PostProfile new];
        
        instance.netAccess = [[NetAccess alloc]init];
        instance.netAccess.delegate = instance;
    });
    
    return instance;
}
- (void)envokeUploadModule
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册中选取", nil];
    actionSheet.tag = 201;
    [actionSheet showInView:APPDELEGATE.mainVC.tabBar];
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 201)
    {
        if (buttonIndex > 1) {
            return;
        }
        //查找位置
        [self uploadPHotoFromCamera:buttonIndex];
    }
    else
    {
        
    }
}
#pragma  mark - 上传照片
- (void)uploadPHotoFromCamera:(NSUInteger)type
{
    pickerImageVC = APPDELEGATE.pickerImageVC;
    if (nil == pickerImageVC)
        pickerImageVC = [[UIImagePickerController alloc] init];//初始化
    
    pickerImageVC.delegate = self;
    pickerImageVC.allowsEditing = NO;//设置可编辑
//    pickerImageVC.allowsEditing = YES;
    switch (type) {
         case TypeCamera:
        {
            //检测设备
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                POPUPINFO(@"未检测到摄像头");
                return;
            }
            
            pickerImageVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerImageVC.showsCameraControls = YES;//是否禁用摄像头空件
        }
            break;
         case TypeAlbum:
        {
            pickerImageVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
            break;
    }
    
    
    [APPDELEGATE.mainVC presentViewController:pickerImageVC animated:YES completion:nil];
    
}

/* 可解开注释以支持自定义操作界面
- (IBAction)takePhoto:(id)sender
{
    [pickerImageVC takePicture];//自动调用代理方法完成照片的拍摄；
}
- (IBAction)switchCamera:(id)sender
{
    pickerImageVC.cameraDevice = 1 -  pickerImageVC.cameraDevice;
}*/

#pragma mark - UIImagePickerDelegate
/**
 *	@brief	照片拾取完成
 *
 *	@param 	picker 	拾取器
 *	@param 	info
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image;
//    image = [info objectForKey:UIImagePickerControllerEditedImage];
//    if(image == nil)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];

    image = [image fixOrientation];
    [[PostManager shareInstance]postProfile].post = image;
    
    
    [APPDELEGATE.mainVC dismissViewControllerAnimated:NO completion:nil];
    PhotoUploadVC *photoUploadVC = [[PhotoUploadVC alloc]init];
    photoUploadVC.uploadDelegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoUploadVC];
//    [pickerImageVC pushViewController:photoUploadVC animated:YES];
    
    [APPDELEGATE.mainVC presentViewController:nav animated:NO completion:nil];
    
}
/**
 *	@brief	照片拾取取消
 *
 *	@param 	picker
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [APPDELEGATE.mainVC dismissViewControllerAnimated:YES completion:nil];
}

/**
 *	@brief	取消视图的方法
 */
- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion
{
    [APPDELEGATE.mainVC dismissViewControllerAnimated:YES completion:nil];

}


/**
 *	@brief	上传图片及信息到本地服务器
 *
 *	@param 	fromVC
 */
- (void)submitPostFromVC:(BaseVC *)fromVC

{
    _currentVC = fromVC;

    if(_postProfile.user == nil)
    {
        POPUPINFO(@"登录失效，请重新登录！");
        [_currentVC stopAview];
        return;
    }
    
    UpYun *uy = [[UpYun alloc]init];
    uy.successBlocker = ^(id data)
    {
        
//        UINavigationController *nav = (UINavigationController *)APPDELEGATE.mainVC.viewControllers[0];
//        HomeVC *homeVC = (HomeVC *)nav.viewControllers[0];
        
        [APPDELEGATE.geoInfoCondition lock];
        while (!APPDELEGATE.isGeoInfoGot) {
            [APPDELEGATE.geoInfoCondition wait];
        }
        [APPDELEGATE.geoInfoCondition unlock];
        if (APPDELEGATE.latitude == 0) {
            [_currentVC stopAview];
            POPUPINFO(@"尝试重启app或设置设备！Sorry");
            return;
        }

        NSLog(@"%@",data);
        
        _postProfile.longitude = [NSNumber numberWithDouble:APPDELEGATE.longitude];
        _postProfile.latitude  = [NSNumber numberWithDouble:APPDELEGATE.latitude];
        
        _postProfile.pic = [[data[@"url"] componentsSeparatedByString:@"/"]lastObject];
        _postProfile.picH = data[@"image-height"];
        _postProfile.picW = data[@"image-width"];
        [self submitToDaFenBaServer];
        
    };
    uy.failBlocker = ^(NSError * error)
    {
        [_currentVC stopAview];
        NSString *message = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"出错啦,请重试或联系打分吧iOS攻城狮" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        NSLog(@"%@",error);
    };
    uy.progressBlocker = ^(CGFloat percent, long long requestDidSendBytes)
    {
        //[_pv setProgress:percent];
    };
    [uy uploadImage:_postProfile.post savekey:[UpYun getSaveKey:@"post"]];
}
- (void)submitToDaFenBaServer
{
    if(![_currentVC.aview isAnimating])
        [_currentVC startAview];
    NSDictionary *para = @{@"post" : @{@"userId"    : _postProfile.user.userId,
                           @"pic"       : STRING_judge(_postProfile.pic),
                           @"picH"      : _postProfile.picH,
                           @"picW"      : _postProfile.picW,
                           @"comment"   : STRING_judge(_postProfile.comment),
                           @"brand"     : STRING_judge(_postProfile.brand),
                           @"texture"   : STRING_judge(_postProfile.texture),
                           @"longitude" : _postProfile.longitude,
                           @"latitude"  : _postProfile.latitude,
                           @"title"     : STRING_judge(_postProfile.title),
                           @"highlight" : STRING_judge(_postProfile.highlight),
                           @"buyUrl"    : STRING_judge(_postProfile. buyUrl),
                           @"buyAddress": STRING_judge(_postProfile.buyAddress)
                           
    }};
    [self.netAccess passUrl:PostModule_add andParaDic:para withMethod:PostModule_add_method andRequestId:PostModule_add_tag thenFilterKey:nil useSyn:NO dataForm:7];

}
#pragma mark - AsynNetAccessDelegate
- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    
    [_currentVC stopAview];
//    PhotoUpLoadSuccessVC *vc = [[PhotoUpLoadSuccessVC alloc]init];
//    [_currentVC.navigationController pushViewController:vc animated:YES];
//    return;
    NSDictionary *receiveDic;
    if (!TYPE_isDictionary(receiveObject))
    {
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
        return;
    }
    else
        receiveDic = (NSDictionary *)receiveObject;
    NSDictionary *result = receiveDic[@"result"];
    if (NETACCESS_Success)
    {

        if ([requestId isEqualToNumber:PostModule_add_tag]) {
            NSDictionary *extInfo = [Coordinator userProfile].extInfo;
            if (extInfo[@"postCount"])
            {
                int oldCount = [extInfo[@"postCount"] intValue];
                [extInfo setValue:NUMBER(oldCount+1) forKey:@"postCount"];
            }

            PhotoUpLoadSuccessVC *vc = [[PhotoUpLoadSuccessVC alloc]init];
            [_currentVC.navigationController pushViewController:vc animated:YES];
        }
    }
    else
        POPUPINFO(STRING_joint(@"上传失败", result[@"msg"]));
    
}
    
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    [_currentVC stopAview];//停止网络访问指示
    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);

}



@end

