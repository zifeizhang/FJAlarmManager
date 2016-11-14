//
//  FJSetMatterViewController.m
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import "FJSetMatterViewController.h"

@interface FJSetMatterViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation FJSetMatterViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.matter.length > 0) {
        self.textView.text = self.matter;
    }
 
    [self.textView becomeFirstResponder];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
}

- (IBAction)returnKeyboardTap:(id)sender {
    
    [self.view endEditing:YES];
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 20) {
        textView.text = [textView.text substringToIndex:20];
    }
}

#pragma mark - click
- (IBAction)backButtonClick:(id)sender {
    
    self.matter = self.textView.text;
    
    if (_alarmMatter) {
        _alarmMatter(self.matter);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
