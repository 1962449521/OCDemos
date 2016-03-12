//
//  LoginViewController.m
//  Password Management
//
//  Created by Mitty on 15/11/20.
//  Copyright © 2015年 Disney. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@property (nonatomic, weak) UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@end

@implementation LoginViewController{
    BOOL _isHaveSetPWD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgLabel.hidden = YES;
    // Do any additional setup after loading the view.
   
//    [alert addAction:[[UIAlertAction alloc]int]
}

- (void) viewDidAppear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"isHaveSet":@NO}];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"PWD":@""}];
    _isHaveSetPWD = [[NSUserDefaults standardUserDefaults] boolForKey:@"isHaveSet"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_isHaveSetPWD?@"please enter your code":@"have not password, please set" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self cancel];
    }];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self done];
    }];
    [alert addAction:cancel];
    [alert addAction:done];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        _textField = textField;
        _textField.secureTextEntry = YES;
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) cancel {
    [_textField setText:@""];
    self.msgLabel.hidden = NO;

    self.msgLabel.text = @"right password is needed!";
}
- (void) done {
    if (!_isHaveSetPWD) {
        [[NSUserDefaults standardUserDefaults] setObject:_textField.text forKey:@"PWD"];
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"isHaveSet"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSString *PWD = [[NSUserDefaults standardUserDefaults] stringForKey:@"PWD"];
    if ([_textField.text isEqualToString:PWD]) {
        UINavigationController *masterVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MasterScene"];
        ((AppDelegate *)[[UIApplication sharedApplication]delegate]).window.rootViewController = masterVC;
        [((AppDelegate *)[[UIApplication sharedApplication]delegate]).window makeKeyAndVisible];
    } else {
        [self cancel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
