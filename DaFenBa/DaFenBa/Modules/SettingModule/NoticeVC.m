//
//  NoticeVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-2.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "NoticeVC.h"
#import "FilterNoticeVC.h"
#import "FilterNoticeTwoGroupVC.h"
#import "SettingManager.h"
#import "SystemAdaptedCell.h"

// MARK: 如需测试接口 请设置如下宏

#define isMOCKDATADebugger NO
#define SLEEP//sleep(1.5)



@interface NoticeVC ()

@property (nonatomic, strong) NSMutableArray *dateSource;

@property (nonatomic, weak) NSMutableArray *checkRecord;

@end

@implementation NoticeVC
{
    NSArray *detailStrs;
    UISwitch *switchView;
}
@synthesize dateSource;
@synthesize checkRecord;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dateSource =[NSMutableArray arrayWithArray:  @[@[@"@我的", @"分析、建议", @"新粉丝"],@[@"私信"]]];
        detailStrs = @[@"不提醒", @"所有人", @"我关注的人"];
        if ([[SettingManager shareInstance]settingDic] == nil || [[[SettingManager shareInstance]settingDic]count]==0 )
        {
            NSMutableArray *arr = [@[@0, @0, @0, @0] mutableCopy];
            [[SettingManager shareInstance]setSettingDic:arr];
            
        }
        checkRecord = [[SettingManager shareInstance]settingDic];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN = YES;
    [self setNavTitle:@"通知和提醒"];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self adaptIOSVersion];
    [self getData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewWillAppear:animated];
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

#pragma mark - 数据获取
- (void)getData
{
    /*
     * load: GET
     ** request: {type: [1], userId: login user id} // type: 1 => @me, 2 => analysis&advice, 3 => new follower, 4 => private message
     ** response: {result: {success: true, msg: error message}, options: [{type: 1, option: 1}, ...]} // type 1: 0 => none, 1 => all, 2 => follow; 2: 0 => none, 1 => all, 2 => follow, 4: 0 => off, 1 => on
     */
    [self startAview];
    if (isMOCKDATADebugger) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SLEEP;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dic = @{@"result": @{@"success": @YES, @"msg": @""}, @"options": @[@{@"type": @1, @"option": @0}, @{@"type": @2, @"option": @1}, @{@"type": @3, @"option": @2}, @{@"type": @4, @"option": @1}]};
                [self receivedObject:dic withRequestId:OptionModule_list_tag];
            });
        });
        
        return;
    }
    NSDictionary *para = @{@"userId" : [Coordinator userProfile].userId, @"type" : @[@1, @2, @3, @4]};
    [self.netAccess passUrl:OptionModule_list andParaDic:para withMethod:OptionModule_list_method andRequestId:OptionModule_list_tag thenFilterKey:nil useSyn:NO dataForm:7];
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
        cell = [[SystemAdaptedCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = dateSource[indexPath.section][indexPath.row];
    
    switch (indexPath.section) {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if ([checkRecord count] > 0) {
                cell.detailTextLabel.text = detailStrs[[checkRecord[indexPath.row] intValue]];
                cell.detailTextLabel.tag = 100 + indexPath.row;
                cell.detailTextLabel.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(detailClicked:)];
                [cell.detailTextLabel addGestureRecognizer:tap];
            }
        }
            break;
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        
            if(switchView == nil)
                switchView = [[UISwitch alloc]init];
            [switchView setTop:cell.contentView.height/2 - switchView.height/2 ];
            [switchView setX:DEVICE_screenWidth - switchView.width - 20.0];
            [switchView addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
            if([checkRecord[3] intValue] == 1)
                [switchView setOn:YES];
            else
                [switchView setOn:NO];
            [cell.contentView addSubview:switchView];
        }
            
        default:
            break;
    }
    
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    
    //ios7.0之前的适配
    if (!(DEVICE_versionAfter7_0)) {
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
    }

    
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView             // Default is 1 {
{
    return [dateSource count];
}
#pragma mark - UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        return indexPath;
    }
    return [NSIndexPath indexPathForRow:-1 inSection:-1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    if (indexPath.row == 1) {
////        FilterNoticeTwoGroupVC *vc = [[FilterNoticeTwoGroupVC alloc]init];
//        FilterNoticeVC *vc = [[FilterNoticeVC alloc]initWithCheckIndex:[checkRecord[1]intValue]];
//        vc.headStr = @"我将收到这些人的分析、建议提醒";
//        vc.tailStr = @"";
//        vc.delegateRowId = 1;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return headToTopHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return headToTopHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSArray *heads = @[@"", @"    通知"];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.text = heads[section];
    [label sizeToFit];
    [label setX:50];
    [label setWidth:100.0];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = textGrayColor;
    return label;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc]init];
}
#pragma mark -用户交互
- (void)switched:(UISwitch *)sender
{
    NSNumber *newOn = sender.on == YES? @1 : @0;
    /*
     * update: PUT
     ** request: {userId: login user id, option: {type: 1, option: 1}}
     ** response: {result: {success: true, msg: error message}}
     */
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
    NSNumber *userId = [Coordinator userProfile].userId;
    NSDictionary *para = @{@"userId": userId, @"option" : @{@"type" : @4, @"option" : newOn}};
    [self.netAccess passUrl:OptionModule_update andParaDic:para withMethod:OptionModule_update_method andRequestId:OptionModule_update_tag thenFilterKey:nil useSyn:NO dataForm:7];
    
    
}
-(void)detailClicked:(UITapGestureRecognizer *)sender
{
    NSArray *headStrArr = @[@"我将收到这些人的@提醒", @"我将收到这些人的分析、建议提醒", @"我将收到这些人的关注提醒"];
    NSArray *tailStrArr = @[@"", @"", @"你仅会收到你所关注人的关注提醒"];
    int processRow = sender.view.tag - 100;
    FilterNoticeVC *filterNoticeVC = [[FilterNoticeVC alloc]initWithCheckIndex:[checkRecord[processRow]intValue]];
        filterNoticeVC.delegateRowId = processRow;
    filterNoticeVC.headStr = headStrArr[processRow];
    filterNoticeVC.tailStr = tailStrArr[processRow];
    [self.navigationController pushViewController:filterNoticeVC animated:YES];
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
        
        if ([requestId isEqualToValue:OptionModule_list_tag])
            POPUPINFO(@"设置信息获取失败");
        else if([requestId isEqualToValue:OptionModule_update_tag])
            POPUPINFO(@"私信设置失败");

        
        return;
    }
    else
    {
        if ([requestId isEqualToValue:OptionModule_list_tag])
        {
            /*
             * load: GET
             ** request: {type: [1], userId: login user id} // type: 1 => @me, 2 => analysis&advice, 3 => new follower, 4 => private message
             ** response: {result: {success: true, msg: error message}, options: [{type: 1, option: 1}, ...]} // type 1: 0 => none, 1 => all, 2 => follow; 2: 0 => none, 1 => all, 2 => follow, 4: 0 => off, 1 => on
             */
            NSArray *arr = receiveObject[@"options"];
            for (NSDictionary *aOption in arr) {
                int index = [aOption[@"type"] intValue] - 1;
                NSNumber *value = aOption[@"option"];
                
                checkRecord[index] = value;
            }
            [self.tableView reloadData];

        }
        else if([requestId isEqualToValue:OptionModule_update_tag])
        {
            checkRecord[3] = switchView.on? @1 : @0;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }

        
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
