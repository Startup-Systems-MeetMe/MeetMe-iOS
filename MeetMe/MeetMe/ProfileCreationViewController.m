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
#import <SSKeychain/SSKeychain.h>

const int BUTTON_CORNER_RADIUS = 4.f;

@interface ProfileCreationViewController () <UITextFieldDelegate, PKImagePickerViewControllerDelegate>

@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (assign, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;

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
    UIVisualEffectView *visualEffectViewTf2 = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    // Textfield
    [self.nameTextField setDelegate:self];
    visualEffectViewTf.frame = self.nameTextField.bounds;
    [self.nameTextField addSubview:visualEffectViewTf];
    
    [self.emailTextField setDelegate:self];
    visualEffectViewTf2.frame = self.emailTextField.bounds;
    [self.emailTextField addSubview:visualEffectViewTf2];
    
    // Profile picture
    [self.profilePicture.layer setCornerRadius:(self.profilePicture.bounds.size.width/2)];
    [self.profilePicture.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.profilePicture.layer setBorderWidth:4.f];
    [self.profilePicture setClipsToBounds:YES];
    
    // Tap Gestures
    UIGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextField)];
    [self.backgroundImageView addGestureRecognizer:dismissGesture];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedNameTextField)];
    [visualEffectViewTf addGestureRecognizer:tapGesture];
    UIGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedEmailTextField)];
    [visualEffectViewTf2 addGestureRecognizer:tapGesture2];
    UIGestureRecognizer *profilePicGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
    [self.profilePicture addGestureRecognizer:profilePicGesture];
    [self.profilePicture setUserInteractionEnabled:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    [self.emailTextField resignFirstResponder];
    [SVProgressHUD show];
    
    // Push to Parse
    NSString *username = self.nameTextField.text;
    NSString *email = self.emailTextField.text;
    NSData *imageData = UIImageJPEGRepresentation(self.selectedImage, 0.4);
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[[CurrentUser sharedInstance] phoneNumber], @"phoneNumber", username, @"name", imageData, @"photo", email, @"email", nil];
    [PFCloud callFunctionInBackground:@"updateNameAndPhoto" withParameters:dict block:^(id object, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (!error) {
            // Create profile instance
            CurrentUser *user = [CurrentUser sharedInstance];
            [user setName:username];
            if (email) [user setEmail:email];
            if (self.selectedImage) [user setProfilePicture:self.selectedImage];
            [user saveToDisk];
            
            // Set password in keychain
            [SSKeychain setPassword:user.phoneNumber forService:RDVSERVICE account:RDVACCOUNT];
            [[NSUserDefaults standardUserDefaults] setObject:RDVSERVICE forKey:RDVACCOUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
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

- (void)touchedNameTextField
{
    if (![self.nameTextField isFirstResponder]) {
        [self.nameTextField becomeFirstResponder];
    }
}

- (void)touchedEmailTextField
{
    if (![self.emailTextField isFirstResponder]) {
        [self.emailTextField becomeFirstResponder];
    }
}

- (void)resignTextField
{
    if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
        
    } else if ([self.emailTextField isFirstResponder]) {
        [self.emailTextField resignFirstResponder];
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

@end
