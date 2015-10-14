//
//  SignupViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 23/09/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "SignupViewController.h"
#import "NSString+Additions.h"
#import "UIImage+animatedGIF.h"
#import <Parse/Parse.h>
#import <SSKeychain/SSKeychain.h>
#import "CurrentUser.h"

const int PHONE_TAG = 99;
const int CODE_TAG = 88;

NSString *RDVSERVICE = @"RDVSERVICE";
NSString *RDVACCOUNT = @"RDVACCOUNT";

@interface SignupViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *activationTextField;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UIView *activationLine;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSString *userPhoneNumber;

@end

@implementation SignupViewController

//------------------------------------------------------------------------------------------
#pragma mark - View Lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Tags to control them in delegate
    self.phoneTextField.tag         = PHONE_TAG;
    self.activationTextField.tag    = CODE_TAG;
    
    // Make sure code textfield and signup button are hidden
    self.activationTextField.alpha  = 0.f;
    self.activationLine.alpha       = 0.f;
    
    // Placeholder colors
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Phone Number" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:250 green:255 blue:255 alpha:1.f] }];
    self.phoneTextField.attributedPlaceholder = str;
    NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@"Phone Number" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:250 green:255 blue:255 alpha:1.f]}];
    self.phoneTextField.attributedPlaceholder = str2;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Is user already signed up?
    if ([SSKeychain passwordForService:RDVSERVICE account:RDVACCOUNT]) {
        // Move post sign-up and profile
        [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"tabBarRoot"] animated:YES];
    } else {
        // Show keyboard
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.phoneTextField becomeFirstResponder];
        });
    }
}

- (void) moveToProfileScreen {
    
    // Hide keyboard
    [self.activationTextField resignFirstResponder];
    
    // Save that user signed-up
    [SSKeychain setPassword:self.userPhoneNumber forService:RDVSERVICE account:RDVACCOUNT];
    [[CurrentUser sharedInstance] setPhoneNumber:self.userPhoneNumber];
    
    // Cover screen
    UIView *background = [[UIView alloc] initWithFrame:self.view.bounds];
    [background setBackgroundColor:self.view.backgroundColor];
    [background setAlpha:0.f];
    [self.view addSubview:background];
    
    // Show animated clock
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 170, 150, 150)];
    [imgView setCenter:CGPointMake(self.view.center.x, 200)];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"clock" withExtension:@"gif"];
    imgView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    [background addSubview:imgView];
    
    // Fade in
    [UIView animateWithDuration:0.7f animations:^{
        background.alpha = 1.f;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"completeProfile"] animated:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
#pragma mark - IBActions -
//------------------------------------------------------------------------------------------

- (IBAction)enteredPhone:(id)sender
{
    // Return early if issue with phone number input
    if (![self.phoneTextField.text isUSPhoneNumber]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Phone #" message:@"Please enter a valid U.S. number." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.userPhoneNumber = self.phoneTextField.text;    // Save phone number
    self.signupButton.alpha = 0.f;                      // Hide done button
    [self.activityIndicator startAnimating];
    
    // Send Parse the phone #
    [PFCloud callFunctionInBackground:@"sendCode" withParameters:@{@"phoneNumber":self.userPhoneNumber} block:^(id object, NSError *error) {
        
        [self.activityIndicator stopAnimating];

        // Success
        if (!error) {
            // Show activation code textfield
            self.signupButton.alpha = 0.f;
            [UIView animateWithDuration:0.2 animations:^{
                self.activationTextField.alpha  = 1.f;
                self.activationLine.alpha       = 1.f;
            } completion:^(BOOL finished) {
                [self.activationTextField becomeFirstResponder];
            }];
        }
        
        // Error
        else {
            // Alert user
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
            // Re-show done button
            self.signupButton.alpha = 1.f;
        }
    }];
}

//------------------------------------------------------------------------------------------
#pragma mark - Handle and Parse US number -
//------------------------------------------------------------------------------------------

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    
    // Prevent from entering letters / symbols
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([string rangeOfCharacterFromSet:notDigits].location != NSNotFound)
        return NO;
    
    // Phone #
    if(textField.tag == PHONE_TAG) {
        
        if (range.length == 1) {
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:YES];
        } else {
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:NO ];
        }
        return NO;
    
    // Activation Code
    } else if (textField.tag == CODE_TAG) {
        
        // Prevent from typing more than 4
        if (totalString.length >= 5)
            return NO;

        // If = 4, check code
        if (totalString.length == 4) {
            
            [self.activityIndicator startAnimating];
            
            // Login through Parse
            [PFCloud callFunctionInBackground:@"logIn" withParameters:@{@"phoneNumber":self.userPhoneNumber, @"codeEntry": totalString} block:^(id object, NSError *error) {
                
                [self.activityIndicator stopAnimating];
                
                // Success
                if (!error) {
                    
                    [self moveToProfileScreen];
                }
                
                // Error
                else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:action];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
            
            return YES;
        }
    }

    return YES;
}

// Helper method
-(NSString*) formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar {
    if(simpleNumber.length==0) return @"";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
    if(simpleNumber.length>10) {
        simpleNumber = [simpleNumber substringToIndex:10];
    }
    
    if(deleteLastChar) {
        simpleNumber = [simpleNumber substringToIndex:[simpleNumber length] - 1];
    }
    
    if(simpleNumber.length < 7)
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"($1) $2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    
    else
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    return simpleNumber;
}

@end
