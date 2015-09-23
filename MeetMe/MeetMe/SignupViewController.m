//
//  SignupViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 23/09/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "SignupViewController.h"
#import "UIImage+animatedGIF.h"
#import <Parse/Parse.h>

int PHONE_TAG = 99;
int CODE_TAG = 88;

NSString *FAKE_CODE = @"0000";

@interface SignupViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *activationTextField;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UIView *activationLine;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Tags to control them in delegate
    self.phoneTextField.tag = PHONE_TAG;
    self.activationTextField.tag = CODE_TAG;
    
    // Make sure code textfield and signup button are hidden
    self.activationTextField.alpha  = 0.f;
    self.activationLine.alpha       = 0.f;
    
    // Placeholder colors
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Phone Number" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:250 green:255 blue:255 alpha:1.f] }];
    self.phoneTextField.attributedPlaceholder = str;
    NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@"Phone Number" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:250 green:255 blue:255 alpha:1.f] }];
    self.phoneTextField.attributedPlaceholder = str2;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Show keyboard
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.phoneTextField becomeFirstResponder];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)enteredPhone:(id)sender
{
    // Prevent from continuing with incomplete number
    if (self.phoneTextField.text.length < 10) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Phone #" message:@"Please enter a valid U.S. number." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // Show activation code textfield
    self.signupButton.alpha = 0.f;
    [UIView animateWithDuration:0.2 animations:^{
        self.activationTextField.alpha  = 1.f;
        self.activationLine.alpha       = 1.f;
    } completion:^(BOOL finished) {
        [self.activationTextField becomeFirstResponder];
    }];
}

// Handle and Parse US number
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
            
            // Fake activation code
            if ([totalString isEqualToString:FAKE_CODE]) {
                
                // Cover screen
                UIView *background = [[UIView alloc] initWithFrame:self.view.bounds];
                [background setBackgroundColor:self.view.backgroundColor];
                [background setAlpha:0.f];
                [self.view addSubview:background];
                
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 170, 150, 150)];
                [imgView setCenter:CGPointMake(self.view.center.x, 200)];
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"clock" withExtension:@"gif"];
                imgView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
                [background addSubview:imgView];
                
                // Fade in
                [UIView animateWithDuration:0.7f animations:^{
                    background.alpha = 1.f;
                }];

                [self moveToNextScreen];
            }
            
            return YES;
        }
    }

    return YES;
}

- (void) moveToNextScreen {
    
    [self.activationTextField resignFirstResponder];
    
    PFObject *numObject = [PFObject objectWithClassName:@"Users"];
    numObject[@"phoneNumber"] = self.phoneTextField.text;
    [numObject saveInBackground];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"homeVC"] animated:YES completion:nil];
    });
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
