//
//  ProfileViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 23/09/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "ProfileCreationViewController.h"
#import <EventKit/EventKit.h>

const int BUTTON_CORNER_RADIUS = 4.f;

@interface ProfileCreationViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (assign, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *calendarAccessButton;
@property (strong, nonatomic) IBOutlet UIButton *contactsAccessButton;

@end

@implementation ProfileCreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Blur
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectViewTf = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    // Textfield
    [self.nameTextField setDelegate:self];
    visualEffectViewTf.frame = self.nameTextField.bounds;
    [self.nameTextField addSubview:visualEffectViewTf];
    
    // Profile picture
    [self.profilePicture.layer setCornerRadius:(self.profilePicture.bounds.size.width/2)];
    [self.profilePicture.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.profilePicture.layer setBorderWidth:4.f];
    [self.profilePicture setClipsToBounds:YES];
    
    // Buttons
    [self.calendarAccessButton.layer setCornerRadius:BUTTON_CORNER_RADIUS];
    [self.calendarAccessButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.calendarAccessButton.layer setBorderWidth:1.f];
    [self.calendarAccessButton setClipsToBounds:YES];
    [self.contactsAccessButton.layer setCornerRadius:BUTTON_CORNER_RADIUS];
    [self.contactsAccessButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.contactsAccessButton.layer setBorderWidth:1.f];
    [self.contactsAccessButton setClipsToBounds:YES];
    
    // Tap Gestures
    UIGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextField)];
    [self.backgroundImageView addGestureRecognizer:dismissGesture];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedTextField)];
    [visualEffectViewTf addGestureRecognizer:tapGesture];
    UIGestureRecognizer *profilePicGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
    [self.profilePicture addGestureRecognizer:profilePicGesture];
    [self.profilePicture setUserInteractionEnabled:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Show keyboard
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.nameTextField becomeFirstResponder];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchedTextField
{
    if (![self.nameTextField isFirstResponder]) {
        [self.nameTextField becomeFirstResponder];
    }
}

- (void)resignTextField
{
    if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
}

- (void)changeImage
{
    NSLog(@"Change profile picture");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)requestAccessToEvents
{
//    EKEventStore *store = [[EKEventStore alloc] init];
//    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//        // handle access here
//    }];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\"Rendez-vous\" Would Like to Access Your Calendar" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"Don\'t Allow" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
