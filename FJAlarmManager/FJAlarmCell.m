//
//  FJAlarmCell.m
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import "FJAlarmCell.h"
#import "FJAlarm.h"

@interface FJAlarmCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *matterLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatCycleLabel;
@property (weak, nonatomic) IBOutlet UIButton *openButton;

@end

@implementation FJAlarmCell
- (void)setAlarm:(FJAlarm *)alarm
{
    if (_alarm != alarm) {
        _alarm = alarm;
    }
    self.timeLabel.text = alarm.time;
    self.matterLabel.text = alarm.matter;
    self.repeatCycleLabel.text = alarm.repeatCycle;
    self.openButton.selected = [alarm.open boolValue];
   
}
- (IBAction)openButtonClick:(id)sender {
    
    BOOL openState = ![self.alarm.open boolValue];
    self.alarm.open = [NSString stringWithFormat:@"%d",openState];
    self.openButton.selected = openState;
    if (_alarmStateChanged) {
        _alarmStateChanged(self.alarm.open);
    }

}
- (void)awakeFromNib {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
