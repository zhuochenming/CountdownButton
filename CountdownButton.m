//
//  CountdownButton.m
//  封装
//
//  Created by 酌晨茗 on 16/1/22.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import "CountdownButton.h"
#import <objc/runtime.h>

#define TitleFont [UIFont systemFontOfSize:13]

#define BacColor [UIColor colorWithRed:59 / 255.0 green:115 / 255.0 blue:211 / 255.0 alpha:1]
#define SelColor [UIColor lightGrayColor]
#define TitleColor [UIColor whiteColor]

static char timerKey;

@interface CountdownButton ()

@end

@implementation CountdownButton

+ (CountdownButton *)buttonWithFrame:(CGRect)frame
                              title:(NSString *)title
                           callBack:(CountdownBlock)block {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:TitleFont];
    button.backgroundColor = BacColor;
    [button addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    return (CountdownButton *)button;
}

#pragma mark - 点击事件
+ (void)sendMessage:(UIButton *)button {
    button.backgroundColor = SelColor;
    [self startWithButton:button time:61 subTitle:@"后重新发送"];
    button.userInteractionEnabled = NO;
}

+ (void)startWithButton:(UIButton *)button
                   time:(NSInteger)timeCount
               subTitle:(NSString *)subTitle {
    
    __block NSInteger timeLeft = timeCount;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    objc_setAssociatedObject(self, &timerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        
        if (timeLeft <= 0) {
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                button.backgroundColor = BacColor;
                [button setTitle:@"重新发送" forState:UIControlStateNormal];
                button.userInteractionEnabled = YES;
            });
        } else {
            NSString *timeString = [NSString stringWithFormat:@"%ld", timeLeft];
            NSLog(@"%@", timeString);
            dispatch_async(dispatch_get_main_queue(), ^{
                button.backgroundColor = SelColor;
                [button setTitle:[NSString stringWithFormat:@"你妹的%@%@", timeString, subTitle] forState:UIControlStateNormal];
                button.userInteractionEnabled = NO;
            });
            timeLeft--;
        }
    });
    dispatch_resume(timer);
}

+ (void)stopTimer {
    dispatch_source_t timer = objc_getAssociatedObject(self, &timerKey);
    if (timer) {
        dispatch_source_cancel(timer);
    }
    objc_setAssociatedObject(self, &timerKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

@end
