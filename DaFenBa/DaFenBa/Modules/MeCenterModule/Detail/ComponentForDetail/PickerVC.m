//
//  GenderPicker.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-31.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//
//备忘：第二列数据加载完前 点击下一步或者 完成 重读省下城市表
#import "PickerVC.h"

@interface PickerVC ()<UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation PickerVC
{
    NSArray *provinces;
    NSArray *cities;
    NSArray *pureProvinces;
    NSCondition *secondColomRenewed;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.view setY:[self.userDelegate view].bottom];
    self.dataPickerView.datePickerMode = UIDatePickerModeDate;
    self.dataPickerView.minimumDate = [self dateFromString:@"19000101"];
    self.dataPickerView.maximumDate = [NSDate date];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDelegate
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.pickerType;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.pickerType == typeSinglepicker)
        return [self.singleSource count];
    switch (component) {
        case 0:
            return [provinces count];
            break;
        case 1:
            return [cities count];
            break;
        default:
            return 0;
            break;
    }

}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)] ;
    if (self.pickerType == typeSinglepicker)
    {
        [label setText:[self.singleSource objectAtIndex:row]];
        
    }
    else
    {
        switch (component) {
            case 0:
                 [label setText:[[provinces objectAtIndex:row] objectForKey:@"State"]];
                break;
            case 1:
                [label setText:[[cities objectAtIndex:row] objectForKey:@"city"]];
                break;
            default:
                return nil;
                break;
        }

    }
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.pickerType == typeSinglepicker)
        return;
    switch (component) {
        case 0:
            cities = [[provinces objectAtIndex:row] objectForKey:@"Cities"];
            [self.pickerView selectRow:0 inComponent:1 animated:NO];
            [self.pickerView reloadComponent:1];
            
            break;
        case 1:
 
            break;
        default:
            break;
    }
}


#pragma mark - NSDate <---> NSString

- (NSDate *)dateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyyMMdd"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}



- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}
#pragma mark - find the index of target in source
- (int)indexOfString:(NSString *)str inArray:(NSArray *)arr
{
    int index = -1;
    for (id target in arr) {
        if (TYPE_isString(target) && [target isEqualToString:str]) {
            index = [arr indexOfObject:target];
        }
    }
    return index;

}

- (NSArray *)purCities:(NSArray *)arr
{
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *aCity in arr) {
        [mutableArr addObject:aCity[@"city"]];
    }
    return [NSArray arrayWithArray:mutableArr];
}

#pragma mark - property setting
- (void) setValue:(NSString *)value
{
    @try {
        if ([STRING_judge(value) isEqualToString:@""]) {
            return;
        }
        if (self.pickerType == typeDataPicker) {
            NSDate *date = [self dateFromString:value];
            [self.dataPickerView setDate:date];
        }
        else if(self.pickerType == typeSinglepicker)
        {
            int index = [self indexOfString:value inArray:self.singleSource];
            if (index == -1) {
                index = 0;
            }
            [self.pickerView selectRow:index inComponent:0 animated:NO];
        }
        else//省市
        {
            int index1 = 0;
            int index2 = 0;
            NSArray *components = [value componentsSeparatedByString:@" "];
            if ([components count] == 1) {
                for (int i = 0; i < 2; i++) {
                    cities = [[provinces objectAtIndex:i] objectForKey:@"Cities"];
                    if ([self indexOfString:value inArray:[self purCities:cities]] > -1) {
                        index1 = i;
                        index2 = [self indexOfString:value inArray:[self purCities:cities]];
                        break;
                    }
                }
            }
            else if([components count] == 2)
            {
                NSString *province = components[0];
                if ([province isEqualToString:@"广西"]
                    ||[province isEqualToString:@"内蒙古"]
                    ||[province isEqualToString:@"新彊"]
                    ||[province isEqualToString:@"宁夏"]
                    ||[province isEqualToString:@"西藏"]) {
                    province = STRING_joint(components[0], @"自治区");
                }
                else province = STRING_joint(components[0], @"省");
                NSString *city = components[1];
                index1 = [self indexOfString:province inArray:pureProvinces];
                if (index1 < 0 ) {
                    index1 = 0;
                }
                cities = [[provinces objectAtIndex:index1] objectForKey:@"Cities"];
                index2 = [self indexOfString:city inArray:[self purCities:cities]];
                if (index2  < 0) {
                    index2 = 0;
                }
            }
            [self.pickerView selectRow:index1 inComponent:0 animated:NO];
            [self.pickerView selectRow:index2 inComponent:1 animated:NO];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"happend erro while setvalue!");
    }
    @finally {
        ;// do nothing, let it die
    }
}

#pragma  mark - 控件使用

/**
 *	@brief	刷新控件type和数据源
 */
- (void)reNewControl
{
    //外观显示
    if (![STRING_judge( self.titlestr) isEqualToString:@""]) {
        self.titlelable.text = self.titlestr;
    }
    
    if (self.pickerType == typeDataPicker) {
        self.pickerView.hidden = YES;
        self.dataPickerView.hidden = NO;
    }
    else
    {
        self.dataPickerView.hidden = YES;
        self.pickerView.hidden = NO;
    }
    //数据源
    if (self.pickerType == typeLocationPicker )
    {
        //加载总数据
        if (provinces == nil && APPDELEGATE.provinces != nil)
        {
            provinces = APPDELEGATE.provinces;
        }
        else
            provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ProvincesAndCities.plist" ofType:nil]];
        //从中提出城市数据
        cities = [[provinces objectAtIndex:0] objectForKey:@"Cities"];
        //从中提出省名数组
        NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *province in provinces) {
            [mutableArr addObject:province[@"State"]];
        }
        pureProvinces = [NSArray arrayWithArray:mutableArr];
        
    }
    //重载数据
    if (self.pickerType != typeDataPicker) {
        [self.pickerView reloadAllComponents];
    }
}

- (void)show
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:kDuration];
    [self.view setY:[self.userDelegate view].height - self.view.height ];
    [self.view setAlpha:1.0f];
    [UIView commitAnimations];
}

- (void)hide
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:kDuration];
    [self.view setAlpha:0.0f];
    [self.view setY:[self.userDelegate view].height];
    [UIView commitAnimations];

}
- (IBAction)finish:(id)sender
{
    NSString *value;
    if (self.pickerType == typeDataPicker) {
        value = [self stringFromDate: self.dataPickerView.date];
    }
    else if(self.pickerType == typeSinglepicker)
    {
        int index = [self.pickerView selectedRowInComponent:0];
        value = self.singleSource[index];
    }
    else
    {
        int index1 = [self.pickerView selectedRowInComponent:0];
        int index2 = [self.pickerView selectedRowInComponent:1];
        NSString *province = provinces[index1][@"State"];
        cities = provinces[index1][@"Cities"];
        if (index2 > [cities count]-1) {
            index2 = 0;
        }
        NSString *city = cities[index2][@"city"];
        if ([province isEqualToString:@"直辖市"] || [province isEqualToString:@"特别行政区"] ) {
            value = city;
        }
        else
        {
            province = [province stringByReplacingOccurrencesOfString:@"省" withString:@""];
            province = [province stringByReplacingOccurrencesOfString:@"自治区" withString:@""];
            value = STRING_joint(STRING_judge(province), @" ");
            value = STRING_joint(value, STRING_judge(city));
        }
    }
    if ([sender isKindOfClass:[UIButton class]] && ((UIButton *)sender).tag != 100) {
        self.isNeedGotoNext = YES;
    }
    [self.userDelegate pickerFinishedWithValue:value From:self];
//    [self hide];

}
- (IBAction)cancel:(id)sender
{
    [self hide];
    [self.userDelegate pickerCancelFrom:self];
    
}



@end

