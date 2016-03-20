//
//  WePayViewController.m
//  weixinPay
//
//  Created by 邱少依 on 16/2/15.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "WePayViewController.h"
#import "WXApiManager.h"
#import "WXApiRequestHandler.h"
#import "PayResultController.h"
@interface WePayViewController ()<WXApiManagerDelegate>

@end

@implementation WePayViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 添加微信支付代理
    [WXApiManager sharedManager].delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [WXApiManager sharedManager].delegate = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *name=[[UILabel alloc] init];
    name.frame=CGRectMake(10, 100, 40, 40);
    name.text=@"金额";
    [self.view addSubview:name];
    UITextField *fieldView=[[UITextField alloc] init];
    fieldView.frame=CGRectMake(60, 100, 200, 40);
    [self.view addSubview:fieldView];
    fieldView.placeholder=@"请输入金额";
    fieldView.borderStyle=UITextBorderStyleLine;
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(CGRectGetMaxX(fieldView.frame)-60, CGRectGetMaxY(fieldView.frame)+10, 60, 40);
    [btn setTitle:@"支付" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor=[UIColor redColor];
    [btn addTarget:self action:@selector(jumpToBizPay) forControlEvents:UIControlEventTouchUpInside];//sendPay:
    [self.view addSubview:btn];
    
    // 添加微信支付代理
    [WXApiManager sharedManager].delegate = self;
    

}

#pragma mark -- 跳转微信支付
- (void)jumpToBizPay
{
    BOOL isInstalled = [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
    if (!isInstalled) {
//        [self showAlertView:@"未安装微信,请安装微信后进行支付"];
        return;
    }
//     [self showHUD:@"正在支付..." isDim:NO];
//    调用后台接口，获取预支付订单
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"journalCode"] = @"168772827582798";//流水号：上界面传过来
    params[@"body"] = @"京东商品";
    params[@"apptype"] = @"Ios";
    
    [[RequestCenter defaultCenter] fetchRespondsForParams:params
       method:@"post"
       apiURL:WXPayURLPath
    beforeRun:^(TCHTTPRequest *request) {
        request.resultBlock = ^(TCHTTPRequest *request, BOOL success) {
            //                                                                    NSLog(@"%@", request.responseObject);
            
            if (request.responseObject==nil ||
                [request.responseObject isKindOfClass:[NSData class]]) {
                [self showHUDComplete:@"支付失败" isCorrect:NO];
                return;
            }
            
            if ([ResultMsg(request.responseObject, @"resultCode") isEqualToString:@"FAIL"]) {
                [self showHUDComplete:request.responseObject[@"errCodeDes"] isCorrect:NO];
                return;
            }
            
            [self hideHUD];
//            获取支付结果字符串
            NSString *message = [self payResult:request.responseObject];
            
            if (message.length > 0) {
                [self showHUDComplete:message isCorrect:NO];
            }
        };
    }];
}

- (NSString *)payResult:(NSDictionary *)params
{
    /*
     prepayid = wx2016030715185652fc1bb1bd0091680790,
     partnerid = 1313711001,
     appid = wx10d9607c9538e68f,
     returnMsg = OK,
     noncestr = 5b1itxcUPKVxQIYB,
     package = Sign=WXPay,
     sign = 9BECF77AD7B8592C72CA0963C1617B0C,
     timestamp = 1457334164,
     returnCode = SUCCESS
     */
    
    if (params) {
        NSMutableString *stamp  = [params objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq *req    = [[PayReq alloc] init];
        req.partnerId  = [params objectForKey:@"partnerid"];
        req.prepayId   = [params objectForKey:@"prepayid"];
        req.nonceStr   = [params objectForKey:@"noncestr"];
        req.timeStamp  = stamp.intValue;
        req.package    = [params objectForKey:@"package"];
        req.sign       = [params objectForKey:@"sign"];
//        [WXApi sendReq:req];
        
        //        +(BOOL) sendAuthReq:(SendAuthReq*) req viewController : (UIViewController*) viewController delegate:(id<WXApiDelegate>) delegate;
        //        [WXApi sendAuthReq:req viewController:self delegate:self];
        //日志输出
        
        BOOL success = [WXApi sendReq:req];
        
        if (success) {
            return @"";
        } else return @"支付错误";
    } else {
        return @"支付错误";
    }
}


#pragma mark -- WXApiManager Delegate
- (void)managerDidRecvPayResponse:(PayResp *)response
{
    //支付返回结果，实际支付结果需要去微信服务器端查询
    NSString *strMsg = [NSString stringWithFormat:@"支付结果"];
    
    switch (response.errCode) {
        case WXSuccess:
        {
            strMsg = @"支付结果：成功！";
            NSLog(@"支付成功－PaySuccess，retcode = %d", response.errCode);
            dispatch_async(dispatch_get_main_queue(), ^{
                PayResultController *resultVC = [[PayResultController alloc] init];
                [self.navigationController pushViewController:resultVC animated:YES];
            });
        }
            break;
            
        default:
        {
            strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", response.errCode,response.errStr];
            NSLog(@"错误，retcode = %d, retstr = %@", response.errCode, response.errStr);
            [self showAlertView:strMsg];
        }
            break;
    }
    
}

//- (NSString *)jumpToBizPay {
//    //============================================================
//    // V3&V4支付流程实现
//    // 注意:参数配置请查看服务器端Demo
//    //============================================================
//    //   预订单生成后的接口：
////    appid=wxb4ba3c02aa476ea1
////    partid=10000100
////    prepayid=wx201602151542042b17a3ffe40192974640
////    noncestr=89af5c828676bc68d85823ce2d17f037
////    timestamp=1455522124
////    package=Sign=WXPay
////    sign=8A21E95D25703FC97B76D04FB7F1CAC9
//    NSString *urlString = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
//    
//    //解析服务端返回json数据
//    NSError *error;
//    //加载一个NSURL对象
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    //将请求的url数据放到NSData对象中
//    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    if ( response != nil) {
//        NSMutableDictionary *dict = NULL;
//        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
//        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
//        
//        NSLog(@"url:%@",urlString);
//        if(dict != nil){
//            NSMutableString *retcode = [dict objectForKey:@"retcode"];
//            if (retcode.intValue == 0){
//                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
//                
//                //调起微信支付
//                PayReq* req             = [[PayReq alloc] init];
//                req.partnerId           = [dict objectForKey:@"partnerid"];
//                req.prepayId            = [dict objectForKey:@"prepayid"];
//                req.nonceStr            = [dict objectForKey:@"noncestr"];
//                req.timeStamp           = stamp.intValue;
//                req.package             = [dict objectForKey:@"package"];
//                req.sign                = [dict objectForKey:@"sign"];
//                [WXApi sendReq:req];
//                //日志输出
//                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
//                return @"";
//            }else{
//                return [dict objectForKey:@"retmsg"];
//            }
//        }else{
//            return @"服务器返回错误，未获取到json对象";
//        }
//    }else{
//        return @"服务器返回错误";
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
