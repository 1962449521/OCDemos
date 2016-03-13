//
//  ViewController.m
//  SrollLayer
//
//  Created by 胡 帅 on 16/3/9.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import "ViewController.h"
#import "SrollLayerView.h"


@interface ViewController ()<SrcollLayerViewDelegate>

@property (weak, nonatomic) IBOutlet SrollLayerView *scrollLayerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cstViewCenterX;

@end

@implementation ViewController

- (void) scrollLayerAnchorPointChange2:(CGPoint)anchorPoint {
    NSLog(@"%f, %f", anchorPoint.x, anchorPoint.y);
    self.cstViewCenterX.constant = -CGRectGetWidth(self.view.frame)/2.0 + anchorPoint.x;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollLayerView.delegate = self;
    
    [self.scrollLayerView setDataSource:[self dataGroupFromJsonFile:@"500_data"]];

}

- (DataGroup *) dataGroupFromJsonFile:(NSString *) fileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@".json"];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath: path]];
    NSArray * jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    DataGroup *dataGroup = [DataGroup new];
    NSMutableArray *mArray = [NSMutableArray array];
    __block double maxValue, minValue, maxTS, minTS;
    minValue = minTS = CGFLOAT_MAX;
    
    [jsonObject enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DataItem *dataItem = [DataItem new];
        dataItem.highValue = [obj[@"highValue"] doubleValue];
        dataItem.lowValue = [obj[@"lowValue"] doubleValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *date = [dateFormatter dateFromString:obj[@"date"]];
        dataItem.timeStamp = [date timeIntervalSince1970];
        
        [mArray addObject:dataItem];
        
        
        maxValue = maxValue > dataItem.highValue? maxValue :  dataItem.highValue;
        minValue = minValue < dataItem.lowValue? minValue :  dataItem.lowValue;
        maxTS    = maxTS > dataItem.timeStamp? maxTS :  dataItem.timeStamp;
        minTS    = minTS < dataItem.timeStamp? minTS :  dataItem.timeStamp;
    }];
    dataGroup.dataArray = [mArray copy];
    dataGroup.maxValue = maxValue;
    dataGroup.minValue = minValue;
    dataGroup.minTS = minTS;
    dataGroup.maxTS = maxTS;
    
    return dataGroup;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
