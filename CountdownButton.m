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

//- (void)viewWillAppearWithButton:(UIButton *)button {
//    NSLog(@"%@", button.superview);
//    for (UIView *next = button.superview; next; next = next.superview) {
//        UIResponder *nextResponder = [next nextResponder];
//        if ([nextResponder isKindOfClass:[UIViewController class]]) {
//            UIViewController *viewController = (UIViewController *)nextResponder;
//            
//            unsigned int conut = 0;
//            Method *methods = class_copyMethodList([viewController class], &conut);
//            for (int i = 0; i < conut; i++) {
//                Method method = methods[i];
//                if (sel_isEqual(method_getName(method), @selector(viewDidDisappear:))) {
//                    Method new = class_getInstanceMethod([self class], @selector(myViewDidDisappear:));
//                    //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
//                    BOOL isAdd = class_addMethod([self class], @selector(myViewDidDisappear:), method_getImplementation(new), method_getTypeEncoding(new));
//                    if (isAdd) {
//                        //如果成功，说明类中不存在这个方法的实现
//                        //将被交换方法的实现替换到这个并不存在的实现
//                        class_replaceMethod([self class], @selector(myViewDidDisappear:), method_getImplementation(method), method_getTypeEncoding(method));
//                    }else{
//                        //否则，交换两个方法的实现
//                        method_exchangeImplementations(method, new);
//                    }
//                }
//            }
//        }
//    }
//}
//
//- (void)myViewDidDisappear:(BOOL)animated {
//
//    
//    NSLog(@"不理解");
//    
//}

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
    dispatch_source_cancel(timer);
    objc_setAssociatedObject(self, &timerKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

@end
