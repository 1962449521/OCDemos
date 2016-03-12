//
//  DetailViewController.m
//  Password Management
//
//  Created by Mitty on 15/11/20.
//  Copyright © 2015年 Disney. All rights reserved.
//

#import "DetailViewController.h"
#define APPDELEGATE ((AppDelegate *) [UIApplication sharedApplication].delegate)

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UILabel *labelnum;
@property (weak, nonatomic) IBOutlet UILabel *labelcode;
@property (weak, nonatomic) IBOutlet UILabel *labelid;
@property (weak, nonatomic) IBOutlet UILabel *labelcom;
@property (weak, nonatomic) IBOutlet UITextField *textfield1;
@property (weak, nonatomic) IBOutlet UITextField *textfield2;
@property (weak, nonatomic) IBOutlet UITextField *textfield3;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet UIButton *editbutton;
@property (weak, nonatomic) IBOutlet UIButton *donebutton;


@end

@implementation DetailViewController

@synthesize isEdit = _isEdit;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
//    self.textfield2.secureTextEntry = YES;
    if (self.password) {
        self.textfield1.text = self.password[@"accountNumber"];
        self.textfield2.text = self.password[@"password"];
        self.textfield3.text = self.password[@"IDNumber"];
        self.textview.text = self.password[@"comment"];

    }
}

- (void) setIsEdit:(BOOL)isEdit{
    _isEdit = isEdit;
    if (isEdit) {
        self.textfield1.borderStyle = UITextBorderStyleRoundedRect;
        self.textfield2.borderStyle = UITextBorderStyleRoundedRect;
        self.textfield3.borderStyle = UITextBorderStyleRoundedRect;
        
        self.textfield1.backgroundColor = [UIColor whiteColor];
        self.textfield2.backgroundColor = [UIColor whiteColor];
        self.textfield3.backgroundColor = [UIColor whiteColor];
        self.textview.backgroundColor = [UIColor whiteColor];
        
        self.textfield1.enabled = YES;
        self.textfield2.enabled = YES;
        self.textfield3.enabled = YES;
        self.textview.userInteractionEnabled = YES;
        self.donebutton.enabled = YES;
        self.editbutton.enabled = NO;
    } else {
        self.textfield1.borderStyle = UITextBorderStyleNone;
        self.textfield2.borderStyle = UITextBorderStyleNone;
        self.textfield3.borderStyle = UITextBorderStyleNone;
        
        self.textfield1.backgroundColor = [UIColor clearColor];
        self.textfield2.backgroundColor = [UIColor clearColor];
        self.textfield3.backgroundColor = [UIColor clearColor];
        self.textview.backgroundColor = [UIColor clearColor];
        
        self.textfield1.enabled = NO;
        self.textfield2.enabled = NO;
        self.textfield3.enabled = NO;
        self.textview.userInteractionEnabled = NO;
        self.editbutton.enabled = YES;
        self.donebutton.enabled = NO;
    }
}
- (BOOL)isEdit{
    return _isEdit;
}
- (IBAction)edit:(id)sender {
    [self setIsEdit:YES];
}
- (IBAction)done:(id)sender {
    [DynamicModel plistNamed:@"DynamicModel" inBackgroundWithBlock:^(PlistModel *plistModel) {
        DynamicModel * dynamicModel = (DynamicModel *)plistModel;
        NSMutableDictionary *dic;
        if ((id)dynamicModel.passwords == [NSNull null]) {
            dic = [NSMutableDictionary dictionary];
        } else {
            dic = [NSMutableDictionary dictionaryWithDictionary:dynamicModel.passwords];
        }
        NSMutableDictionary *password = [NSMutableDictionary dictionary];
        [password setValue:self.textfield1.text forKey:@"accountNumber"];
        [password setValue:self.textfield2.text forKey:@"password"];
        [password setValue:self.textfield3.text forKey:@"IDNumber"];
        [password setValue:self.textview.text forKey:@"comment"];
        [password setValue:@(self.index) forKey:@"sortIndex"];

        if (self.password) {
            [dic removeObjectForKey:self.password[@"accountNumber"]];
        }
        [dic setValue:password forKey:password[@"accountNumber"]];
        dynamicModel.passwords = [NSDictionary dictionaryWithDictionary: dic];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];

        });
    }];
    
}
- (IBAction)touchDown:(id)sender {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.textview.layer.borderWidth = 1;
    self.textview.layer.borderColor = [[UIColor grayColor] CGColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isEdit = _isEdit;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
