//
//  FJCoreDataManager.h
//  FJAlarmManager
//
//  Created by belter on 16/7/20.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FJAlarm.h"
#define EntityName @"FJAlarm"

@interface FJCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

+ (instancetype)manager;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


// 插入数据
- (void)insertCoreDataWithAlarm:(FJAlarm *)alarm;

// 查询
- (NSInteger)fetchAlarmCount;
- (NSMutableArray *)fetchAllAlarm;
- (FJAlarm *)fetchAlarmWithAlarmID:(NSString *)alarmID;

// 删除
- (void)deleteAllAlarm;
- (void)deleteAlarmWithAlarmID:(NSString *)alarmID;

// 更新
- (void)updateAlarmWithAlarmID:(NSString *)alarmID isOpen:(NSString *)open;
- (void)updateAlarm:(FJAlarm *)alarm withAlarmID:(NSString *)alarmID;

// 生成新的 alarmID
- (NSString *)getNewAlarmID;





@end
