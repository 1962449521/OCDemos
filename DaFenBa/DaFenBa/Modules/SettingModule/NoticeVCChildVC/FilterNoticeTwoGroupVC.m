//
//  FilterNoticeTwoGroupVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-2.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "FilterNoticeTwoGroupVC.h"
#import "SystemAdaptedCell.h"

@interface FilterNoticeTwoGroupVC ()

@property (nonatomic, strong) NSArray *dateSource;
@property (nonatomic, strong) NSMutableArray *checkRecord;

@end

@implementation FilterNoticeTwoGroupVC

@synthesize dateSource;
@synthesize checkRecord;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dateSource = @[@[@"所有人", @"我关注的人"], @[@"所有人", @"我关注的人",@"不提醒"]];
        checkRecord = [NSMutableArray arrayWithArray: @[@0, @0]];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN = YES;
    [self setNavTitle:@"分析、建议"];
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
    cell.textLabel.text = dateSource[indexPath.section][indexPath.row];
    if (indexPath.row == [checkRecord[indexPath.section] intValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType  = UITableViewCellAccessoryNone;

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
    
    
    checkRecord[indexPath.section] =  [NSNumber numberWithInt:indexPath.row];
    [self.tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    switch (section) {
        case 0:
            return headToTopHeight*2;
            break;
        case 1:
            return headToTopHeight*2;
        default:
            break;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSArray *heads = @[@"    允许哪些人评论我", @"    我将收到这些人的评论"];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.text = heads[section];
    [label sizeToFit];
    [label setX:50];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = textGrayColor;
    return label;
}

@end
