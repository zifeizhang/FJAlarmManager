//
//  FJSetMatterViewController.h
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJSetMatterViewController : UIViewController
@property (nonatomic,copy) void (^alarmMatter)(NSString *matterStr);
@property (nonatomic,strong) NSString *matter;
@end
