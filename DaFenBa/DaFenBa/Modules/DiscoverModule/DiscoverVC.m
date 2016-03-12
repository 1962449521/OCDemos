//
//  DiscoverVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-24.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "DiscoverVC.h"
#import "OtherHomeVC.h"
#import "InviteVC.h"

@interface DiscoverVC ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *dateSource;
@property (nonatomic, strong) NSArray *icons;

@end

@implementation DiscoverVC

@synthesize icons;
@synthesize dateSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        dateSource =[NSMutableArray arrayWithArray:@[@[@"打分达人", @"分享达人"],@[@"专家", @"建议榜"]]];
//        icons = @[@[@"discoveryIcon1", @"discoveryIcon2"],@[@"discoveryIcon3", @"discoveryIcon4"]];
        dateSource =[NSMutableArray arrayWithArray:@[@[@"分享达人", @"打分达人"]]];
        icons = @[@[@"discoveryIcon2", @"discoveryIcon1" ]];
       
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedHideBack = YES;
    [self setNavTitle:@"发现"];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchBar.delegate = self;
    
    self.linkLabel1.userInteractionEnabled = YES;
    self.linkLabel1.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(linkLableClicked2)];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(linkLableClicked)];
    [self.linkLabel1 addGestureRecognizer:tap];
    [self.linkLabel2 addGestureRecognizer:tap1];
    

    
    [self adaptIOSVersion];

}




- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    [super viewWillAppear:animated];
}
- (void)linkLableClicked{
    OtherHomeVC *vc = [[OtherHomeVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)linkLableClicked2{
InviteVC *vc = [[InviteVC alloc]init];
[self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 视图适应IOS版本
- (void)adaptIOSVersion
{
    [super adaptIOSVersion:self.tableView];
    //searchbar 适配
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ([self.searchBar respondsToSelector:@selector(barTintColor)]) {
        float iosversion7_1 = 7.1;
        if (version >= iosversion7_1)
        {
            //iOS7.1
            [[[[self.searchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
        }
        else
        {
            //iOS7.0
            [self.searchBar setBarTintColor:[UIColor clearColor]];     }
    }
    else
    {
        //iOS7.0以下
        [[self.searchBar.subviews objectAtIndex:0] removeFromSuperview];
    }
    [self.searchBar setBackgroundColor:ColorRGB(200.0, 200.0, 200.0)];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dateSource[section]count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SettingCell";
    BaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[BaseCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    [cell.imageView setImage:[UIImage imageNamed:icons[indexPath.section][indexPath.row]]];
    cell.textLabel.text = dateSource[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    cell.textLabel.userInteractionEnabled = YES;

    UIControl *control = [[UIControl alloc]initWithFrame:CGRectZero];
    [cell.textLabel.superview addSubview:control];
    [control setWidth:DEVICE_screenWidth];
    [control setHeight:44];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(linkLableClicked2)];
    [control addGestureRecognizer:tap];
    
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
    OtherHomeVC *vc = [[OtherHomeVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
#pragma  mark - 用户交互
- (IBAction)controlClicked:(UIControl *)sender
{
   // NSString *str = STRING_fromInt(sender.tag);
    POPUPINFO(@"click");
}

//UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    InviteVC *vc = [[InviteVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];

}

@end