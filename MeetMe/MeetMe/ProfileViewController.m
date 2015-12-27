//
//  ProfileViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 29/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "ProfileViewController.h"
#import "CurrentUser.h"
#import "UIColor+Additions.h"
#import <PKImagePicker/PKImagePickerViewController.h>
#import <Parse/Parse.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ProfileViewController () <PKImagePickerViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UIView *fakeImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UIButton *profilePictureButton;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text                = [[CurrentUser sharedInstance] name];
    self.phoneLabel.text               = [[CurrentUser sharedInstance] phoneNumber];
    self.profilePictureImageView.image = [[CurrentUser sharedInstance] profileImage];
    
    [self.profilePictureImageView setClipsToBounds:YES];
    self.profilePictureImageView.layer.borderColor = [UIColor rdvTertiaryColor].CGColor;
    self.profilePictureImageView.layer.borderWidth = 2.0;
    self.profilePictureImageView.layer.cornerRadius = floor(self.profilePictureImageView.bounds.size.width / 2.f);
    
    // Change Profile picture button
    self.profilePictureButton.layer.borderWidth = 1.f;
    self.profilePictureButton.layer.borderColor = [UIColor rdvTertiaryColor].CGColor;
    self.profilePictureButton.layer.cornerRadius = 5.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)changeProfilePicture:(id)sender
{
    PKImagePickerViewController *imagePicker = [[PKImagePickerViewController alloc]init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imageSelected:(UIImage *)img
{
    NSData *imageData = UIImageJPEGRepresentation(img, 0.4);
    NSDictionary *params = @{@"photo":imageData,
                             @"phoneNumber":[[CurrentUser sharedInstance] phoneNumber],
                             @"name": [[CurrentUser sharedInstance] name],
                             @"email": [[CurrentUser sharedInstance] email]};
    [PFCloud callFunctionInBackground:@"updateNameAndPhoto" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"Failed saving profile picture. Please try again later."];
            return;
        }
        
        [[CurrentUser sharedInstance] setProfilePicture:img];
        [self.profilePictureImageView setImage:img];
    }];
}

- (void)imageSelectionCancelled
{
    // Nothing to do
}

@end
