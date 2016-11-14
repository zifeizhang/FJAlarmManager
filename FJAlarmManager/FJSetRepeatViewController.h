//
//  FJSetRepeatViewController.h
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJSetRepeatViewController : UIViewController

@property (nonatomic,copy) void (^repeatWeekdays)(NSMutableArray *weekdays);
@property (nonatomic,strong) NSMutableArray *resultArr;

@end
