//
//  FJSetRepeatViewController.m
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import "FJSetRepeatViewController.h"
#import "FJUtility.h"

@interface FJSetRepeatViewController ()
@property (weak, nonatomic) IBOutlet UITableView *weekdayTableView;
@property (nonatomic,strong) NSArray *weekdayNumArr;  // 用来传递


@end

@implementation FJSetRepeatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.weekdayNumArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if ([self.resultArr containsObject:self.weekdayNumArr[indexPath.row]]) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [FJUtility weekdayName:self.weekdayNumArr[indexPath.row]];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.resultArr containsObject:self.weekdayNumArr[indexPath.row]])
    {
        [self.resultArr addObject:self.weekdayNumArr[indexPath.row]];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    else
    {
        [self.resultArr removeObject:self.weekdayNumArr[indexPath.row]];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - click
- (IBAction)backbuttonClick:(id)sender {
    
    // 排序
    if (self.resultArr.count > 1) {
        self.resultArr = [NSMutableArray arrayWithArray:[self.resultArr sortedArrayUsingSelector:@selector(compare:)]];
    }
    
    // 传值
    if (_repeatWeekdays) {
        _repeatWeekdays(self.resultArr);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
/*
- (IBAction)saveButtonClick:(id)sender {

    // 排序
    if (self.resultArr.count > 1) {
        self.resultArr = [NSMutableArray arrayWithArray:[self.resultArr sortedArrayUsingSelector:@selector(compare:)]];
    }
    
    // 传值
    if (_repeatWeekdays) {
        _repeatWeekdays(self.resultArr);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
*/


#pragma mark - getter
- (NSArray *)weekdayNumArr
{
    if (!_weekdayNumArr) {
        _weekdayNumArr = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    }
    return _weekdayNumArr;

}
- (NSMutableArray *)resultArr
{
    if (!_resultArr) {
        _resultArr = [NSMutableArray array];
    }
    return _resultArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
