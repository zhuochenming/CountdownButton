//
//  CountdownButton.h
//  CountButton
//
//  Created by 酌晨茗 on 16/1/22.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BacColor [UIColor colorWithRed:59 / 255.0 green:115 / 255.0 blue:211 / 255.0 alpha:1]
#define SelColor [UIColor lightGrayColor]
#define TitleColor [UIColor whiteColor]

typedef void(^CountingBlock)();
typedef void(^CdCompleteBlock)();

static CGFloat const countFontSize = 14;

@interface CountdownButton : UIButton

+ (NSTimeInterval)timeIntervalToSecond:(NSInteger)second;

#pragma mark - 验证码倒计时
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title startTime:(NSInteger)startTime tapEvent:(CountingBlock)tapBlock callBack:(CdCompleteBlock)completeBlock;
//直接从某个时间开始倒计时
- (void)startWithTime:(NSInteger)timeCount;

#pragma mark - 天数倒计时
- (instancetype)initWithFrame:(CGRect)frame leftTime:(NSTimeInterval)leftTime;

#pragma mark - 计时
- (instancetype)initWithFrame:(CGRect)frame;

#warning 必须在- (void)viewDidDisappear:(BOOL)animated 里停掉计时器
- (void)stopTimer;

@end
