//
//  FJCoreDataManager.m
//  FJAlarmManager
//
//  Created by belter on 16/7/20.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import "FJCoreDataManager.h"

@implementation FJCoreDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+ (instancetype)manager
{
    static FJCoreDataManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[FJCoreDataManager alloc]init];
        
    });
    return manager;
    
}

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack
- (NSManagedObjectModel *)managedObjectModel {

    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FJAlarmManager" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FJAlarmManager.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
    
        abort();
    }
    
    return _persistentStoreCoordinator;
}
- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - 数据库操作
// 插入数据
- (void)insertCoreDataWithAlarm:(FJAlarm *)alarm
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    FJAlarm *newAlarm = [NSEntityDescription insertNewObjectForEntityForName:EntityName inManagedObjectContext:context];
    newAlarm.time = alarm.time;
    newAlarm.matter = alarm.matter;
    newAlarm.repeatCycle = alarm.repeatCycle;
    newAlarm.open = alarm.open;
    newAlarm.alarmID = alarm.alarmID;


    NSError *error;
    if (![context save:&error]) {
        
        NSLog(@"【CoreData 插入数据失败】alarmID: %@,%@",alarm.alarmID,[error localizedDescription]);
    }else
    {
        //        NSLog(@"【CoreData 插入数据成功】alarmID :%@",alarm.alarmID);
    }
    
}

- (NSInteger)fetchAlarmCount
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    return fetchedObjects.count;
}
// 查询
- (NSMutableArray *)fetchAllAlarm
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // NSFetchRequest: 获取数据的请求
    // NSEntityDescription: 实体结构
    
    // 1.创建请求
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    // 指定查询的实体结构（表）
    NSEntityDescription *entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    // 2.进行查询，返回对应的数据记录数组（NSManagedObject数组）
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *resultArray = [NSMutableArray array];
    for (FJAlarm *alarm in fetchedObjects) {
        
        [resultArray addObject:alarm];
        
    }
    return resultArray;
    
}
- (FJAlarm *)fetchAlarmWithAlarmID:(NSString *)alarmID
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"alarmID like[cd] %@", alarmID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        
        NSLog(@"【CoreData 查询失败】alarmID :%@,%@",alarmID,error.localizedDescription);
        return nil;
        
    }else
    {
        FJAlarm *alarm = [fetchedObjects firstObject];
        return alarm;
    }
    
}

// 删除
- (void)deleteAllAlarm
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!error && datas && [datas count]) {
        
        for (NSManagedObject *object in datas) {
            
            [context deleteObject:object];
            
        }
        
        if (![context save:&error]) {
            
            NSLog(@"error:%@",error);
        }
        
    }
}

// 删除某个闹钟
- (void)deleteAlarmWithAlarmID:(NSString *)alarmID
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"alarmID like[cd] %@", alarmID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!error && fetchedObjects && [fetchedObjects count]) {
        
        for (NSManagedObject *object in fetchedObjects) {
            
            [context deleteObject:object];
            
        }
        
        if (![context save:&error]) {
            
            NSLog(@"error:%@",error);
        }
        
    }else
    {
        NSLog(@"【CoreData 删除数据失败】alarmID :%@,%@",alarmID,error.localizedDescription);
        
    }
    
    
}


// 更新
- (void)updateAlarm:(FJAlarm *)alarm withAlarmID:(NSString *)alarmID;
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // 建立 fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    request.entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"alarmID like[cd] %@",alarmID];
    
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    for (FJAlarm *alarm in results) {

        alarm.time = alarm.time;
        alarm.repeatCycle = alarm.repeatCycle;
        alarm.open = alarm.open;
        alarm.matter = alarm.matter;
    }
    
    // 保存
    if ([context save:&error]) {
        
        //        NSLog(@"【CoreData 更新数据成功】alarmID :%@",alarmID);
        
    }else
    {
        NSLog(@"【CoreData 更新数据失败】alarmID :%@,%@",alarmID,error.localizedDescription);
    }
    
}

// 更新
- (void)updateAlarmWithAlarmID:(NSString *)alarmID isOpen:(NSString *)open;
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // 建立 fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    request.entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"alarmID like[cd] %@",alarmID];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    for (FJAlarm *alarm in results) {
        
        alarm.open = open;
    }
    
    // 保存
    if ([context save:&error]) {
        
        //        NSLog(@"【CoreData 更新数据成功】alarmID :%@",alarmID);
        
    }else
    {
        NSLog(@"【CoreData 删除数据失败】alarmID :%@,%@",alarmID,error.localizedDescription);
    }
    
}



#pragma mark - 生成新的 alarmID
- (NSString *)getNewAlarmID
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // NSFetchRequest: 获取数据的请求
    // NSEntityDescription: 实体结构
    
    // 1.创建请求
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    // 指定查询的实体结构（表）
    NSEntityDescription *entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    
    // 2.进行查询，返回对应的数据记录数组（NSManagedObject数组）
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *existIDArray = [NSMutableArray array];   // 已存在的ID
    for (FJAlarm *alarm in fetchedObjects) {
        
        [existIDArray addObject:alarm.alarmID];
    }
    
    NSArray *allArr = [self allIdArr];
    
    NSMutableArray *newArr = [NSMutableArray array];
    for (int i = 0; i < allArr.count; i++) {
        
        
        if (![existIDArray containsObject:allArr[i]]) {
            
            [newArr addObject:allArr[i]];
        }
        
    }
    
    if (newArr.count > 0) {
        
        return [newArr firstObject];
    }else
    {
        return nil;
    }
}

- (NSArray *)allIdArr
{
    return @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19"];
    
    //    return @[@"0",@"1",@"2",@"3",@"4",@"5"];
}


@end
