//
//  ProfileViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 29/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "ProfileViewController.h"
#import "CurrentUser.h"

@interface ProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text                = [[CurrentUser sharedInstance] name];
    self.phoneLabel.text               = [[CurrentUser sharedInstance] phoneNumber];
    self.profilePictureImageView.image = [[CurrentUser sharedInstance] profileImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
