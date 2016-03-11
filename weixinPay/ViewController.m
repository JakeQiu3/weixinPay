//
//  ViewController.m
//  weixinPay
//
//  Created by 邱少依 on 16/2/15.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(100, 100, 100, 50);
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pushVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.backgroundColor=[UIColor blueColor];
}

- (void)pushVC {
    Class cls;
    cls = NSClassFromString(@"WePayViewController");
    UIViewController *viewC = [[cls alloc] init];
    [self.navigationController pushViewController:viewC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
