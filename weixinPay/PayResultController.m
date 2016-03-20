//
//  PayResultController.m
//  VinuxPost
//
//  Created by qsy on 15/8/26.
//  Copyright (c) 2015年 qsy. All rights reserved.
//

#import "PayResultController.h"

@interface PayResultController ()

@end

@implementation PayResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"navigation_back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"navigation_back.png"] forState:UIControlStateHighlighted];
    backButton.frame = CGRectMake(0, 0, 30, 30);
    backButton.showsTouchWhenHighlighted = 1;
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (IBAction)backToHome:(id)sender {
    [self backAction];
}

#pragma mark -- 
- (void)backAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
