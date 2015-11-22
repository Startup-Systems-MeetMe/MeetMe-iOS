//
//  NewMeetingViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 12/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "NewMeetingViewController.h"
#import "LandingPageViewController.h"

@interface NewMeetingViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UIButton *meetWithButton;
@property (strong, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation NewMeetingViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.notesTextView setText:@"Notes"];
    
    [self.meetWithButton setTitle:[NSString stringWithFormat:@"With %@", [self.contactsToMeetWith objectAtIndex:0]] forState:UIControlStateNormal];
    
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
