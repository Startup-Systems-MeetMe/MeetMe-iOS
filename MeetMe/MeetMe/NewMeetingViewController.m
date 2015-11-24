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
#import "User.h"

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

//------------------------------------------------------------------------------------------
#pragma mark - View lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.notesTextView setText:@"Notes"];
    
    // Buttons
    NSString *withWho = @"With";
    for (User *user in self.contactsToMeetWith) {
        withWho = [withWho stringByAppendingFormat:@" %@,", user.name];
    }
    // Remove last comma
    withWho = [withWho substringToIndex:withWho.length-1];
    
    [self.meetWithButton setTitle:withWho forState:UIControlStateNormal];
    
    // Add borders & corner radius
    self.thisWeekButton.layer.borderWidth = 1.f;
    self.thisWeekButton.layer.borderColor = [UIColor rdvTertiaryColor].CGColor;
    self.thisWeekButton.layer.cornerRadius = 5.f;
    self.nextWeekButton.layer.borderWidth = 1.f;
    self.nextWeekButton.layer.borderColor = [UIColor rdvTertiaryColor].CGColor;
    self.nextWeekButton.layer.cornerRadius = 5.f;
    
    // Initial button state: this week is selected
    [self.thisWeekButton setBackgroundColor:[UIColor rdvTertiaryColor]];
    [self.thisWeekButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextWeekButton setBackgroundColor:[UIColor clearColor]];
    [self.nextWeekButton setTitleColor:[UIColor rdvTertiaryColor] forState:UIControlStateNormal];
    
    // Setup date picker
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self setUpDatePickerForThisWeek:YES];
    
    // Tap to dismiss keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
#pragma mark - Date picker -
//------------------------------------------------------------------------------------------

- (void)setUpDatePickerForThisWeek:(BOOL)thisWeek
{
    // Minimum date, can't scroll before that
    [self.datePicker setMinimumDate:[NSDate date]];
    
    // Find this Sunday
    if (thisWeek) {
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [gregorian setLocale:[NSLocale currentLocale]];
        NSDateComponents *nowComponents = [gregorian components:NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:today];
        [nowComponents setWeekday:1];
        NSDate *thisSunday = [gregorian dateFromComponents:nowComponents];
        [self.datePicker setDate:thisSunday];
        
    // Set to next week
    } else {
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 7;
        NSDate *oneWeekFromNow = [[NSCalendar currentCalendar] dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
        [self.datePicker setDate:oneWeekFromNow];
    }
}

- (void)datePickerValueChanged:(id)sender
{
    // Deselect both buttons
    [UIView animateWithDuration:0.1f animations:^{
        [self.thisWeekButton setBackgroundColor:[UIColor clearColor]];
        [self.thisWeekButton setTitleColor:[UIColor rdvTertiaryColor] forState:UIControlStateNormal];
        
        [self.nextWeekButton setBackgroundColor:[UIColor clearColor]];
        [self.nextWeekButton setTitleColor:[UIColor rdvTertiaryColor] forState:UIControlStateNormal];
    }];
}

//------------------------------------------------------------------------------------------
#pragma mark - IBActions -
//------------------------------------------------------------------------------------------

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

- (IBAction)tappedThisWeek:(id)sender
{
    [UIView animateWithDuration:0.2f animations:^{
        [self.thisWeekButton setBackgroundColor:[UIColor rdvTertiaryColor]];
        [self.thisWeekButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.nextWeekButton setBackgroundColor:[UIColor clearColor]];
        [self.nextWeekButton setTitleColor:[UIColor rdvTertiaryColor] forState:UIControlStateNormal];
    }];
    
    [self setUpDatePickerForThisWeek:YES];
}

- (IBAction)tappedNextWeek:(id)sender
{
    [UIView animateWithDuration:0.2f animations:^{
        [self.nextWeekButton setBackgroundColor:[UIColor rdvTertiaryColor]];
        [self.nextWeekButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.thisWeekButton setBackgroundColor:[UIColor clearColor]];
        [self.thisWeekButton setTitleColor:[UIColor rdvTertiaryColor] forState:UIControlStateNormal];
    }];
    
    [self setUpDatePickerForThisWeek:NO];
}

- (IBAction)goBackToContacts:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------------------
#pragma mark - TextField -
//------------------------------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

@end
