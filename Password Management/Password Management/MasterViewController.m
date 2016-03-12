//
//  MasterViewController.m
//  Password Management
//
//  Created by Mitty on 15/11/20.
//  Copyright © 2015年 Disney. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "DynamicModel.h"
#import "LoginViewController.h"
#define APPDELEGATE ((AppDelegate *) [UIApplication sharedApplication].delegate)


@interface MasterViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *objects;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [DynamicModel plistNamed:@"DynamicModel" inBackgroundWithBlock:^(PlistModel *plistModel) {
        DynamicModel * dynamicModel = (DynamicModel *)plistModel;
        if ((id)dynamicModel.passwords == [NSNull null]) {
            dynamicModel.passwords = @{@"bank account" : @{@"accountNumber":@"bank account",
                                                           @"password":@"",
                                                           @"IDNumber":@"",
                                                           @"comment":@"",
                                                           @"sortIndex": @0},
                                       @"my email" : @{@"accountNumber":@"my email",
                                                       @"password":@"",
                                                       @"IDNumber":@"",
                                                       @"comment":@"",
                                                       @"sortIndex": @1},
                                       @"game LOL": @{@"accountNumber":@"game LOL",
                                                      @"password":@"",
                                                      @"IDNumber":@"",
                                                      @"comment":@"",
                                                      @"sortIndex": @2}};
        }
        NSMutableArray *arr = [NSMutableArray array];
        NSArray *sortedKey = [dynamicModel.passwords.allKeys sortedArrayUsingComparator:^NSComparisonResult(id   obj1, id   obj2) {
            return [dynamicModel.passwords[obj1][@"sortIndex"] compare:dynamicModel.passwords[obj2][@"sortIndex"]];
        }];
        [sortedKey enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
            [arr addObject:dynamicModel.passwords[obj]];
        }];
        
        self.objects = [NSArray arrayWithArray:arr];
        [self.tableView reloadData];
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addNewObject:(id)sender {
    DetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    [self.navigationController pushViewController:detailVC animated:YES];
    
    detailVC.isEdit = YES;
    detailVC.index = self.objects.count;
}
- (IBAction)resetEnterCode:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PWD"];
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"isHaveSet"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    LoginViewController *vc = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    APPDELEGATE.window.rootViewController = vc;
    [APPDELEGATE.window makeKeyAndVisible];

}

#pragma mark - Table View  UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.password = self.objects[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
    
    detailVC.isEdit = NO;
    detailVC.index = [self.objects[indexPath.row][@"sortIndex"] integerValue];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row >= 3;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *keyStr = cell.textLabel.text;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [DynamicModel plistNamed:@"DynamicModel" inBackgroundWithBlock:^(PlistModel *plistModel) {
            DynamicModel * dynamicModel = (DynamicModel *)plistModel;
            NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dynamicModel.passwords];
            NSInteger removedIndex = [mDic[keyStr][@"sortIndex"] integerValue];
            [mDic removeObjectForKey:keyStr];
            [mDic enumerateKeysAndObjectsUsingBlock:^(id   key, id   obj, BOOL *  stop) {
                NSDictionary *valueDic = [NSMutableDictionary dictionaryWithDictionary:obj];
                if ([valueDic[@"sortIndex"] integerValue] > removedIndex) {
                    [valueDic setValue:@([valueDic[@"sortIndex"] integerValue] - 1) forKey:@"sortIndex"];
                }
            }];
            
            dynamicModel.passwords = [NSDictionary dictionaryWithDictionary:mDic];
            
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.objects];
            [arr removeObjectAtIndex:indexPath.row];
            self.objects = [NSArray arrayWithArray:arr];

            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        }];

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSDictionary *object = self.objects[indexPath.row];
    cell.textLabel.text = object[@"accountNumber"];
    NSString *cellImageName = @"cell_";
    if (indexPath.row < 3) {
        cellImageName = [cellImageName stringByAppendingString:[NSString stringWithFormat:@"%@",@(indexPath.row)] ];
    } else {
        cellImageName = @"cell_other";
    }
    cell.imageView.image = [UIImage imageNamed:cellImageName];
    return cell;
}




@end
