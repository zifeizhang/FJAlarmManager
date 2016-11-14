//
//  FJAlarm.h
//  FJClock
//
//  Created by belter on 16/7/9.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FJAlarm : NSObject

@property(nonatomic,strong) NSString *time;
@property(nonatomic,strong) NSString *repeatCycle;
@property(nonatomic,strong) NSString *matter;
@property(nonatomic,assign) NSString *open;

@property (nonatomic,assign) NSString *alarmID;

@end
