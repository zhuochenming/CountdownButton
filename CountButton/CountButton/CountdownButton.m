//
//  CountdownButton.m
//  CountButton
//
//  Created by 酌晨茗 on 16/1/22.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import "CountdownButton.h"
#import <objc/runtime.h>

static char secondTimerKey;
static char dayTimerKey;

@interface CountdownButton ()

@property (nonatomic, copy) CountingBlock tapBlock;

@property (nonatomic, copy) CdCompleteBlock completeBlock;

@property (nonatomic, strong) UILabel *dayLabel;

@property (nonatomic, strong) UILabel *hourLabel;

@property (nonatomic, strong) UILabel *minuteLabel;

@property (nonatomic, strong) UILabel *secondLabel;

@end

@implementation CountdownButton

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title tapEvent:(CountingBlock)tapBlock callBack:(CdCompleteBlock)completeBlock {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tapBlock = tapBlock;
        self.completeBlock = completeBlock;
        
        [self setTitle:title forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:countFontSize]];
        self.backgroundColor = BacColor;
        [self addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame leftTime:(NSTimeInterval)leftTime {
    self = [super initWithFrame:frame];
    if (self) {
        [self configurationViewWithFrame:frame];
        
        [self timeCountLeftWithTimeInterval:leftTime];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configurationViewWithFrame:frame];
        [self timeCountFromZero];
    }
    return self;
}

- (void)configurationViewWithFrame:(CGRect)frame {
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    CGFloat offset = 10;
    CGFloat lableWidth = (width - 3 * offset) / 4.0;
    
    self.dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lableWidth, height)];
    self.dayLabel.textAlignment = NSTextAlignmentCenter;
    self.dayLabel.font = [UIFont systemFontOfSize:14];
    self.dayLabel.textColor = [UIColor redColor];
    [self addSubview:_dayLabel];
    
    self.hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_dayLabel.frame) + offset, 0, lableWidth, height)];
    self.hourLabel.textAlignment = NSTextAlignmentCenter;
    self.hourLabel.font = [UIFont systemFontOfSize:14];
    self.hourLabel.textColor = [UIColor redColor];
    [self addSubview:_hourLabel];
    
    UILabel *firstLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_hourLabel.frame), 0, offset, height)];
    firstLable.text = @"：";
    firstLable.font = [UIFont systemFontOfSize:14];
    [self addSubview:firstLable];
    
    self.minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_hourLabel.frame) + offset, 0, lableWidth, height)];
    self.minuteLabel.textAlignment = NSTextAlignmentCenter;
    self.minuteLabel.font = [UIFont systemFontOfSize:14];
    self.minuteLabel.textColor = [UIColor redColor];
    [self addSubview:_minuteLabel];
    
    UILabel *secondLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_minuteLabel.frame), 0, offset, height)];
    secondLable.text = @"：";
    secondLable.font = [UIFont systemFontOfSize:14];
    [self addSubview:secondLable];
    
    self.secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_minuteLabel.frame) + offset, 0, lableWidth, height)];
    self.secondLabel.textAlignment = NSTextAlignmentCenter;
    self.secondLabel.font = [UIFont systemFontOfSize:14];
    self.secondLabel.textColor = [UIColor redColor];
    [self addSubview:_secondLabel];
}

#pragma mark - 点击事件
- (void)sendMessage:(UIButton *)button {
    if (self.tapBlock) {
        self.tapBlock();
    }
    button.backgroundColor = SelColor;
    [self startWithButton:button time:61 subTitle:@"秒"];
    button.userInteractionEnabled = NO;
}

- (void)startWithButton:(UIButton *)button time:(NSInteger)timeCount subTitle:(NSString *)subTitle {
    
    __block NSInteger timeLeft = timeCount;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    objc_setAssociatedObject(self, &secondTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        
        if (timeLeft <= 0) {
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.completeBlock) {
                    self.completeBlock();
                }
                
                dispatch_source_t secondTimer = objc_getAssociatedObject(self, &secondTimerKey);
                if (secondTimer) {
                    dispatch_source_cancel(secondTimer);
                    secondTimer = nil;
                }
                
                button.backgroundColor = BacColor;
                [button setTitle:@"重新发送" forState:UIControlStateNormal];
                button.userInteractionEnabled = YES;
            });
        } else {
            NSString *timeString = [NSString stringWithFormat:@"%ld", timeLeft];
            dispatch_async(dispatch_get_main_queue(), ^{
                button.backgroundColor = SelColor;
                [button setTitle:[NSString stringWithFormat:@"剩余%@%@", timeString, subTitle] forState:UIControlStateNormal];
                button.userInteractionEnabled = NO;
            });
            timeLeft--;
        }
    });
    dispatch_resume(timer);
}

- (void)timeCountLeftWithTimeInterval:(NSTimeInterval)leftTime {    
    __block NSInteger timeout = leftTime;
    if (timeout != 0) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        objc_setAssociatedObject(self, &dayTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
        //每秒执行
        dispatch_source_set_event_handler(timer, ^{
            if(timeout <= 0) {
                //倒计时结束，关闭
                dispatch_source_t dayTimer = objc_getAssociatedObject(self, &dayTimerKey);
                if (dayTimer) {
                    dispatch_source_cancel(dayTimer);
                    dayTimer = nil;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.dayLabel.text = @"";
                    self.hourLabel.text = @"00";
                    self.minuteLabel.text = @"00";
                    self.secondLabel.text = @"00";
                });
            } else {
                NSInteger days = (NSInteger)(timeout / (3600 * 24));
                if (days == 0) {
                    self.dayLabel.text = @"";
                }
                NSInteger hours = (NSInteger)((timeout - days * 24 * 3600) / 3600);
                NSInteger minute = (NSInteger)(timeout - days * 24 * 3600 - hours * 3600) / 60;
                NSInteger second = timeout - days * 24 * 3600 - hours * 3600 - minute * 60;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (days == 0) {
                        self.dayLabel.text = @"0天";
                    } else {
                        self.dayLabel.text = [NSString stringWithFormat:@"%lu天", days];
                    }
                    if (hours < 10) {
                        self.hourLabel.text = [NSString stringWithFormat:@"0%lu", hours];
                    } else {
                        self.hourLabel.text = [NSString stringWithFormat:@"%lu", hours];
                    }
                    if (minute < 10) {
                        self.minuteLabel.text = [NSString stringWithFormat:@"0%lu", minute];
                    } else {
                        self.minuteLabel.text = [NSString stringWithFormat:@"%lu", minute];
                    }
                    if (second < 10) {
                        self.secondLabel.text = [NSString stringWithFormat:@"0%lu", second];
                    } else {
                        self.secondLabel.text = [NSString stringWithFormat:@"%lu", second];
                    }
                });
                timeout--;
            }
        });
        dispatch_resume(timer);
    }
}

- (void)timeCountFromZero {
    __block NSInteger secondCount = 0;
    __block NSInteger minuteCount = 0;
    __block NSInteger hourCount = 0;
    __block NSInteger dayCount = 0;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    objc_setAssociatedObject(self, &dayTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    //每秒执行
    dispatch_source_set_event_handler(timer, ^{
            if (secondCount > 59) {
                secondCount = 0;
                minuteCount++;
            }
            
            if (minuteCount > 59) {
                minuteCount = 0;
                hourCount++;
            }
            
            if (hourCount > 23) {
                hourCount = 0;
                dayCount++;
            }

            dispatch_sync(dispatch_get_main_queue(), ^{
                if (dayCount == 0) {
                    self.dayLabel.text = @"0天";
                } else {
                    self.dayLabel.text = [NSString stringWithFormat:@"%lu天", dayCount];
                }
                if (hourCount < 10) {
                    self.hourLabel.text = [NSString stringWithFormat:@"0%lu", hourCount];
                } else {
                    self.hourLabel.text = [NSString stringWithFormat:@"%lu", hourCount];
                }
                if (minuteCount < 10) {
                    self.minuteLabel.text = [NSString stringWithFormat:@"0%lu", minuteCount];
                } else {
                    self.minuteLabel.text = [NSString stringWithFormat:@"%lu", minuteCount];
                }
                if (secondCount < 10) {
                    self.secondLabel.text = [NSString stringWithFormat:@"0%lu", secondCount];
                } else {
                    self.secondLabel.text = [NSString stringWithFormat:@"%lu", secondCount];
                }
            });
            secondCount++;
    });
    dispatch_resume(timer);
}

+ (void)stopTimer {
    dispatch_source_t secondTimer = objc_getAssociatedObject(self, &secondTimerKey);
    if (secondTimer) {
        dispatch_source_cancel(secondTimer);
        secondTimer = nil;
    }
    objc_setAssociatedObject(self, &secondTimerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    dispatch_source_t dayTimer = objc_getAssociatedObject(self, &dayTimerKey);
    if (dayTimer) {
        dispatch_source_cancel(dayTimer);
        dayTimer = nil;
    }
    objc_setAssociatedObject(self, &dayTimerKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - 工具
+ (NSTimeInterval)timeIntervalToSecond:(NSInteger)second {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *endDate = [dateFormatter dateFromString:[self getCalendarDateString]];
    
    NSDate *startDate = [NSDate date];
    NSDate *resultDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([endDate timeIntervalSinceReferenceDate] + second)];
    
    NSTimeInterval timeInterval =[resultDate timeIntervalSinceDate:startDate];
    return timeInterval;
}

+ (NSString *)getCalendarDateString {
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dayString = [formatter stringFromDate:now];
    return dayString;
}

@end
