//
//  PlanetVC.m
//  Solar
//
//  Created by 胡 帅 on 15/12/1.
//  Copyright © 2015年 Disney. All rights reserved.
//

#import "PlanetVC.h"
#import <CoreGraphics/CoreGraphics.h>

@interface PlanetVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblPlanetName;
@property (weak, nonatomic) IBOutlet UITextView *txvIntro;
@property (weak, nonatomic) IBOutlet UISlider *sldVelocity;
@property (weak, nonatomic) IBOutlet UISlider *sldTravelTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDistanceTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDistace;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UIButton *btnShowDisantView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcHeight;
@property (weak, nonatomic) IBOutlet UIView *viewAlert;
@property (weak, nonatomic) IBOutlet UILabel *lblVelocity;
@property (weak, nonatomic) IBOutlet UILabel *lblTravelTime;
@end

@implementation PlanetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sldVelocity.minimumValue = 100;
    self.sldVelocity.maximumValue = 800;
    self.sldTravelTime.minimumValue = self.km/800.0;
    self.sldTravelTime.maximumValue = self.km/100.0;
//    self.sldTravelTime.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
    self.lblPlanetName.text = [NSString stringWithFormat:@"  %@  ", self.planetName];
    [self resetBtnClicked:nil];
    
    
    
    
    
    
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.lineSpacing = 5.0;
    para.paragraphSpacing = 10.0;
    para.firstLineHeadIndent = 20;
    para.alignment = NSTextAlignmentJustified;
    self.txvIntro.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *masStr = [[NSMutableAttributedString alloc] initWithString:self.intro attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                    NSBackgroundColorAttributeName:[UIColor clearColor],
                    NSParagraphStyleAttributeName:para,
                                                                                                                  NSFontAttributeName: [UIFont systemFontOfSize:15.0]}];
    self.lblDistanceTitle.text = [NSString stringWithFormat:@"Distance between %@ and Earth:",self.planetName];
    self.lblDistace.text = [NSString stringWithFormat:@"%@*10^4km",@(self.km)];
    
    self.txvIntro.attributedText = masStr;
    if ([self.planetName isEqualToString:@"Earth"]) {
        self.btnShowDisantView.hidden = YES;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)segmentChanged:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            [self.view removeFromSuperview];
            break;
    
        case 1: {
            NSInteger index = (self.view.tag +1) % self.parentViewController.childViewControllers.count;
            PlanetVC *vc = self.parentViewController.childViewControllers[index];
            [self willMoveToParentViewController:nil];
            [self.parentViewController transitionFromViewController:self
                              toViewController:vc
                                      duration:0.3
                                       options:UIViewAnimationOptionTransitionFlipFromLeft
                                    animations:^{}
                                    completion:^(BOOL finished) {
                                    }];
            [self didMoveToParentViewController:self];
        }
        default:
            break;
    }

}
- (IBAction)switchShowDistance:(id)sender {
    NSString *title;
    if (self.lcHeight.constant == 0) {
        self.lcHeight.constant = 300;
        title = @"Hide distance panel";
    } else {
        self.lcHeight.constant = 0;
        title = @"Show distance panel";
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.viewAlert layoutIfNeeded];
        [self.btnShowDisantView setTitle:title forState:UIControlStateNormal];
    }];
}
- (IBAction)sementClicked:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.lblDistace.text = [NSString stringWithFormat:@"%@*10^4km", @(self.km)];
            break;
            case 1:
            self.lblDistace.text = [NSString stringWithFormat:@"%@*10^4mile", @(self.mile)];
            
        default:
            break;
    }
}
- (IBAction)resetBtnClicked:(id)sender {
    float orign = 200;
    self.lblVelocity.text = [NSString stringWithFormat:@"Velocity = %@ km/s",@((int)(orign))];
    self.sldVelocity.value = orign;
    NSInteger travelTime = (NSInteger)(self.km/orign);
    self.lblTravelTime.text = [NSString stringWithFormat:@"Travel time = %@ *10^4s",@(travelTime)];
    self.sldTravelTime.value = (float)travelTime;
}
- (IBAction)sldVelocityChanged:(UISlider *)sender {
    NSLog(@"slider-velocity:%@", @(sender.value));
    self.lblVelocity.text = [NSString stringWithFormat:@"Velocity = %@ km/s",@((int)(sender.value))];
    float travelTime = (self.km*1.0/sender.value);
    self.lblTravelTime.text = [NSString stringWithFormat:@"Travel time = %@ *10^4s",@(travelTime)];
    self.sldTravelTime.value = travelTime;
}
- (IBAction)sldTravelTimeChanged:(UISlider *)sender {
    NSLog(@"slider-travelTime%@", @(sender.value));

    self.lblTravelTime.text = [NSString stringWithFormat:@"Travel time = %@ *10^4s",@((int)(sender.value))];
    NSInteger velocity = (NSInteger)(self.km/sender.value);
    self.lblVelocity.text = [NSString stringWithFormat:@"Velocity = %@ km/s",@(velocity)];
    self.sldVelocity.value = velocity;
}
- (IBAction)gotoWiki:(id)sender {
    NSURL* url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://en.wikipedia.org/wiki/%@", self.planetName]];
    [[ UIApplication sharedApplication]openURL:url];
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
