//
//  FJAlarmEditViewController.h
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJAlarm.h"
#import "AppDelegate.h"
typedef enum : NSUInteger {
    
    FJAlarmViewModeEdit,
    FJAlarmViewModeAdd,
    
} FJAlarmViewMode;

@interface FJAlarmEditViewController : UIViewController

@property (nonatomic,strong) FJAlarm *alarm;
//@property (nonatomic,assign) NSInteger alarmIndex;

@end
