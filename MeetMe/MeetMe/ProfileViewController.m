//
//  ProfileViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 23/09/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "ProfileViewController.h"

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
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
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
