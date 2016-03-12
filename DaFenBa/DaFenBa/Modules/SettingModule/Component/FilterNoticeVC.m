//
//  FilterNoticeVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-2.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "FilterNoticeVC.h"
#import "SettingManager.h"
#import "SystemAdaptedCell.h"

@interface FilterNoticeVC ()

@property (nonatomic, strong) NSArray *dateSource;

@end


// MARK: 如需测试接口 请设置如下宏

#define isMOCKDATADebugger NO
#define SLEEP

@implementation FilterNoticeVC
{
    int tempIndex;
}

@synthesize dateSource;
@synthesize checkRecord;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dateSource = @[@[ @"不提醒", @"所有人", @"我关注的人"]];
        checkRecord = [NSMutableArray arrayWithArray: @[@NO, @NO, @NO]];
    }
    return self;
}
- (id)initWithCheckIndex:(NSUInteger)checkIndex
{
    FilterNoticeVC *instance = [self init];
    if (instance) {
        checkRecord[checkIndex] = @YES;
    }
    return instance;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN = YES;
    NSArray *tilteArr = @[@"@我的设置", @"分析、建议设置", @"新粉丝设置"];
    [self setNavTitle:tilteArr[self.delegateRowId]];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self adaptIOSVersion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 适应IOS版本
- (void)adaptIOSVersion
{
    [super adaptIOSVersion:self.tableView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dateSource[section]count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SettingCell";
    SystemAdaptedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SystemAdaptedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
if ([checkRecord[indexPath.row] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = dateSource[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    
    //ios7.0之前的适配
    if (!(DEVICE_versionAfter7_0)) {
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dateSource count];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    tempIndex = indexPath.row;
    
    BOOL indexVaule = [checkRecord[indexPath.row] boolValue];
    if(indexVaule == YES) return;
    
    NSNumber *type = [NSNumber numberWithInt: self.delegateRowId + 1];
    NSNumber *option = [NSNumber numberWithInt:indexPath.row];
    NSNumber *userId = [Coordinator userProfile].userId;
    NSDictionary *para = @{@"userId" : userId, @"option" : @{@"type": type, @"option" : option}};
    
    [self startAview];
    if (isMOCKDATADebugger) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SLEEP;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dic = @{@"result": @{@"success": @YES, @"msg": @""}};
                [self receivedObject:dic withRequestId:OptionModule_update_tag];
            });
        });
        return;
    }
    
    
    [self.netAccess passUrl:OptionModule_update andParaDic:para withMethod:OptionModule_update_method andRequestId:OptionModule_update_tag thenFilterKey:nil useSyn:NO dataForm:7];
    /*
     * update: PUT
     ** request: {userId: login user id, option: {type: 1, option: 1}}
     ** response: {result: {success: true, msg: error message}}
     
     */
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return headToTopHeight * 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return headToTopHeight * 2;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.headStr == nil) self.headStr = @"";
    NSArray *heads = @[self.headStr, @""];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.text = heads[section];
    [label sizeToFit];
    [label setX:50];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = textGrayColor;
    return label;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(self.tailStr == nil) self.tailStr = @"";
    NSArray *tails = @[self.tailStr, @""];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.text = tails[section];
    [label sizeToFit];
    [label setX:50];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = textGrayColor;
    return label;

}
//#pragma mark - backtoPre
//- (void)backToPreVC:(id)sender
//{
//    int index = 0;
//    for (NSNumber *num in checkRecord) {
//        if ([num boolValue]) {
//            index = [checkRecord indexOfObject:num];
//        }
//    }
//    
//}

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
        POPUPINFO(@"设置失败");
        return;
    }
    else
    {
        checkRecord =  [NSMutableArray arrayWithArray: @[@NO, @NO, @NO]];
        [checkRecord replaceObjectAtIndex:tempIndex withObject:@YES];
        
        NSNumber *num = [NSNumber numberWithInt:tempIndex];
        NSMutableArray *arr = [[SettingManager shareInstance]settingDic];
        [arr replaceObjectAtIndex:self.delegateRowId withObject:num];
        
        
        [self.tableView reloadData];
        
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
