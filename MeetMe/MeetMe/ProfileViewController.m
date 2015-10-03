//
//  ProfileViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 23/09/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "ProfileViewController.h"
#import <EventKit/EventKit.h>

@interface ProfileViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameTextField setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
