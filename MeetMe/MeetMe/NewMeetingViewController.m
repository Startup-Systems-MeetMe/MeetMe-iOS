//
//  NewMeetingViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 12/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "NewMeetingViewController.h"

@interface NewMeetingViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation NewMeetingViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Date Picker
    [self.datePicker setMinimumDate:[NSDate date]];
    
    // Tap to dismiss keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissKeyboard {
    [self.titleTextField resignFirstResponder];
    [self.notesTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
