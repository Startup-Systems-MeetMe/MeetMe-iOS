//
//  ProfileViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 23/09/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "ProfileCreationViewController.h"
#import <EventKit/EventKit.h>
#import <Contacts/Contacts.h>
#import <PKImagePicker/PKImagePickerViewController.h>
#import "CurrentUser.h"
#import <Parse/Parse.h>
#import "UIImage+Additions.h"
#import <SVProgressHUD/SVProgressHUD.h>

const int BUTTON_CORNER_RADIUS = 4.f;

@interface ProfileCreationViewController () <UITextFieldDelegate, PKImagePickerViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (assign, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *calendarAccessButton;
@property (strong, nonatomic) IBOutlet UIButton *contactsAccessButton;

@end

@implementation ProfileCreationViewController

//------------------------------------------------------------------------------------------
#pragma mark - View Lifecycle -
//------------------------------------------------------------------------------------------

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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.nameTextField becomeFirstResponder];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tappedFinish:(id)sender
{
    // Make sure name is not empty
    if (self.nameTextField.text.length == 0) {
        [self flashTextFieldBackground];
        [self.nameTextField becomeFirstResponder];
        return;
    }
    
    [self.nameTextField resignFirstResponder];
    [SVProgressHUD show];
    
    // Push to Parse
    NSString *username = self.nameTextField.text;
    NSData *imageData = UIImageJPEGRepresentation(self.selectedImage, 0.4);
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[[CurrentUser sharedInstance] phoneNumber], @"phoneNumber", username, @"name", imageData, @"photo", nil];
    [PFCloud callFunctionInBackground:@"updateNameAndPhoto" withParameters:dict block:^(id object, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (!error) {
            // Create profile instance
            CurrentUser *user = [CurrentUser sharedInstance];
            [user setName:self.nameTextField.text];
            if (self.selectedImage) [user setProfilePicture:self.selectedImage];
            
            // Move to TabBar
            [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"tabBarRoot"] animated:YES];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

//------------------------------------------------------------------------------------------
#pragma mark - Handling the textfield -
//------------------------------------------------------------------------------------------

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)flashTextFieldBackground
{
    UIColor *color = self.nameTextField.backgroundColor;
    NSTimeInterval duration = 0.3;
    
    [UIView animateWithDuration:duration animations:^{
        self.nameTextField.backgroundColor = [UIColor colorWithRed:0.710 green:0.267 blue:0.267 alpha:1.000];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            self.nameTextField.backgroundColor = color;
        }];
    }];
}

//------------------------------------------------------------------------------------------
#pragma mark - Profile Image -
//------------------------------------------------------------------------------------------

- (void)changeImage
{
    PKImagePickerViewController *imagePicker = [[PKImagePickerViewController alloc]init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imageSelected:(UIImage *)img
{
    [self.profilePicture setImage:img];
    self.selectedImage = img;
}

- (void)imageSelectionCancelled
{
    // Nothing to do
}

//------------------------------------------------------------------------------------------
#pragma mark - Access Calendar & Contacts -
//------------------------------------------------------------------------------------------

-(IBAction)requestAccessToEvents
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        // handle access here
    }];
}

-(IBAction)requestAccessToContacts:(id)sender
{
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // handle access here
    }];
}

@end
