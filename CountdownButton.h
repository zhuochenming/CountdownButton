//
//  CountdownButton.h
//  封装
//
//  Created by 酌晨茗 on 16/1/22.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CountdownBlock)();

@interface CountdownButton : UIButton

+ (CountdownButton *)buttonWithFrame:(CGRect)frame
                              title:(NSString *)title
                           callBack:(CountdownBlock)block;


#warning viewWillDisappear里停掉计时器
+ (void)stopTimer;

@end
