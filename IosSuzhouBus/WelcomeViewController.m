//
//  WelcomeViewController.m
//  IosSuzhouBus
//
//  Created by 黄传一 on 9/18/16.
//  Copyright © 2016 黄传一. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController (){
    UISwitch *mySwitch;
    UITextView *textview;
}

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addSwitch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)switched:(id)sender{
    NSLog(@"Switch current state %@", mySwitch.on ? @"On" : @"Off");
}
-(void)addSwitch{
    mySwitch = [[UISwitch alloc] init];
    [self.view addSubview:mySwitch];
    mySwitch.center = CGPointMake(150, 200);
    [mySwitch addTarget:self action:@selector(switched:)
       forControlEvents:UIControlEventValueChanged];
}


@end




////弹框
//-(void)addAlertView{
//    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
//                              @"Title" message:@"This is a test alert" delegate:self
//                                             cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
//    [alertView show];
//}
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:
//(NSInteger)buttonIndex{
//    switch (buttonIndex) {
//        case 0:
//            NSLog(@"Cancel button clicked");
//            break;
//        case 1:
//            NSLog(@"OK button clicked");
//            break;
//
//        default:
//            break;
//    }
//}

////滑块
//-(IBAction)sliderChanged:(id)sender{
//    NSLog(@"SliderValue %f",mySlider.value);
//}
//-(void)addSlider{
//    mySlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 200, 200, 23)];
//    [self.view addSubview:mySlider];
//    mySlider.minimumValue = 10.0;
//    mySlider.maximumValue = 99.0;
//    mySlider.continuous = NO;
//    [mySlider addTarget:self action:@selector(sliderChanged:)
//       forControlEvents:UIControlEventValueChanged];
//}


//
////开关
//-(IBAction)switched:(id)sender{
//    NSLog(@"Switch current state %@", mySwitch.on ? @"On" : @"Off");
//}
//-(void)addSwitch{
//    mySwitch = [[UISwitch alloc] init];
//    [self.view addSubview:mySwitch];
//    mySwitch.center = CGPointMake(150, 200);
//    [mySwitch addTarget:self action:@selector(switched:)
//       forControlEvents:UIControlEventValueChanged];
//}


//// 文本
//-(void)addTextView{
//    myTextView = [[UITextView alloc]initWithFrame:
//                  CGRectMake(10, 50, 300, 300)];
//    [myTextView setText:@"Lorem: ipsum dolor: sit er: elit lamet:, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt inculpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicingpecu, sed do eiusmod tempor incididunt ut labore et dolore magna aiqua.Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisialiquip ex ea commodo consequat. Duis aute irure dolor in reprehenderitin voluptate velit esse cillum dolore eu fugiat nulla pariatur.Excepteur sint occaecat cupidatat non proident, sunt in culpaqui officia deserunt mollit anim id est laborum. Nam liber te conscientto factor tum poen legum odioque civiuda."];
//     myTextView.delegate = self;
//     [self.view addSubview:myTextView];
//
//     }

