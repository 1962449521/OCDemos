//
//  SettingHomeVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-2.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "SettingHomeVC.h"
#import "SystemAdaptedCell.h"

@interface SettingHomeVC ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *dateSource;

@end

@implementation SettingHomeVC

@synthesize dateSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dateSource = @[@[@"通知和提醒", @"意见反馈", @"帐号安全", @"关于"], @[@"退出当前帐号"]];
        dateSource = @[@[@"通知和提醒", @"意见反馈",  @"关于"], @[@"退出当前帐号"]];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN = YES;
    [self setNavTitle:@"设置"];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //[self adaptIOSVersion];

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
    cell.textLabel.text = dateSource[indexPath.section][indexPath.row];
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 1) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = ColorRGB(224.0, 66.0, 49.0);
        cell.accessoryType = UITableViewCellAccessoryNone;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    NSArray *vcs = @[@"NoticeVC", @"FeedBackVC", @"SecurityVC", @"AboutVC"];
    NSArray *vcs = @[@"NoticeVC", @"FeedBackVC",  @"AboutVC"];

    
    switch (indexPath.section) {
        case 0:
        {
            Class clazz = NSClassFromString(vcs[indexPath.row]);
            BaseVC *vc = (BaseVC *)[[clazz alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            UIAlertView *alerview = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定退出此帐号？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alerview.delegate = self;
            [alerview show];
        }
        default:
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return headToTopHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
#pragma mark - UIAlertViewDelegate 退出登录
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
        {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [Coordinator loginOut];
            HSLog(@"%@", [MemberManager shareInstance]);

            
        }
            break;
        default:
            break;
    }
}


@end
