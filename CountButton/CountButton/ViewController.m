//
//  ViewController.m
//  CountButton
//
//  Created by Zhuochenming on 16/7/4.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import "ViewController.h"
#import "CountdownButton.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat hegith = 40;
    CGFloat buttonWidth = 100;
    CGFloat left = (width - buttonWidth) / 2.0;

    CountdownButton *firstButton = [[CountdownButton alloc] initWithFrame:CGRectMake(left, 150, buttonWidth, hegith) title:@"发送验证码" tapEvent:^{
        NSLog(@"tap");
    } callBack:^{
        NSLog(@"complete");
    }];
    
    [self.view addSubview:firstButton];
    
    CountdownButton *secondButton = [[CountdownButton alloc] initWithFrame:CGRectMake(left - 25, 250, buttonWidth + 50, hegith) leftTime:[CountdownButton timeIntervalToSecond:48 * 3600]];
    [self.view addSubview:secondButton];
    
    CountdownButton *thirdButton = [[CountdownButton alloc] initWithFrame:CGRectMake(left - 25, 350, buttonWidth + 50, hegith)];
    [self.view addSubview:thirdButton];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [CountdownButton stopTimer];
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
