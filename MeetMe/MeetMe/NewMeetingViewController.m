//
//  NewMeetingViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 12/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "NewMeetingViewController.h"
#import "LandingPageViewController.h"
#import "UIColor+Additions.h"

@interface NewMeetingViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

// Buttons
@property (strong, nonatomic) IBOutlet UIButton *meetWithButton;
@property (strong, nonatomic) IBOutlet UIButton *thisWeekButton;
@property (strong, nonatomic) IBOutlet UIButton *nextWeekButton;

@end

@implementation NewMeetingViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.notesTextView setText:@"Notes"];
    
    // Buttins
    [self.meetWithButton setTitle:[NSString stringWithFormat:@"With %@", [self.contactsToMeetWith objectAtIndex:0]] forState:UIControlStateNormal];
    self.thisWeekButton.layer.borderWidth = 1.f;
    self.thisWeekButton.layer.borderColor = [UIColor rdvTertiaryColor].CGColor;
    self.thisWeekButton.layer.cornerRadius = 5.f;
    
    self.nextWeekButton.layer.borderWidth = 1.f;
    self.nextWeekButton.layer.borderColor = [UIColor rdvTertiaryColor].CGColor;
    self.nextWeekButton.layer.cornerRadius = 5.f;
    
    // Date Picker
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 7;
    NSDate *oneWeekFromNow = [[NSCalendar currentCalendar] dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    [self.datePicker setMinimumDate:[NSDate date]];
    [self.datePicker setDate:oneWeekFromNow];
    
    // Tap to dismiss keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)saveMeeting:(id)sender
{
    // No title
    if (self.titleTextField.text.length == 0) {
        [self.titleTextField becomeFirstResponder];
        
    // Return to home page
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Notes"]) {
        textView.text = @"";
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Notes";
    }
    [textView resignFirstResponder];
}

- (void)dismissKeyboard {
    [self.titleTextField resignFirstResponder];
    [self.notesTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
