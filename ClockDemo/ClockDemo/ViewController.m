//
//  ViewController.m
//  ClockDemo
//
//  Created by 胡 帅 on 16/3/18.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import "ViewController.h"
#import "HSClockView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet HSClockView *clockView;
@property (weak, nonatomic) IBOutlet UITextField *txfTime;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // 代码创建方式
//    _clockView = [[HSClockView alloc] initWithFrame:CGRectMake(0, 20, 200, 200)];
//    [self.view addSubview:_clockView];
    
    // 设置钟表背景
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bg_dail@2x" ofType:@".png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    [_clockView setDialBackGroundImage:image];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.clockView  addObserver:self forKeyPath:@"time" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.clockView removeObserver:self forKeyPath:@"time"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_clockView setTime:[[NSDate date] timeIntervalSince1970]];
}

- (IBAction)segmentControlClicked:(UISegmentedControl *)sender {
    [self.txfTime resignFirstResponder];
    switch (sender.selectedSegmentIndex) {
        case 0://设置
            if([[self.txfTime.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0) {
                NSString *dateStr = [NSString stringWithFormat:@"2016-01-01 %@",self.txfTime.text];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH-mm-ss";
                NSDate *date = [dateFormatter dateFromString:dateStr];
                NSTimeInterval time = [date timeIntervalSince1970];
                [self.clockView setTime:time];
                sender.selectedSegmentIndex = 2;
            }
            break;

        case 1://暂停
            [self.clockView pause];
            break;

        case 2://运行
            [self.clockView work];
            break;

        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    NSTimeInterval newTime = [change[NSKeyValueChangeNewKey] doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:newTime];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    NSString *strTime = [NSString stringWithFormat:@"%02ld : %02ld : %02ld", (components.hour % 12), (components.minute), (components.second)];
    self.navigationItem.title = strTime;
}

- (void)dealloc {
    NSLog(@"view controller of clock view dealloced");
}


@end
