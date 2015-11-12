//
//  TabBarController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 10/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "TabBarController.h"
#import "LandingPageViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Default tab
    [self setSelectedIndex:1];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"Create-unselected"];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"Create-selected"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tappedCreateButton) forControlEvents:UIControlEventTouchDown];
    CGFloat x = self.tabBar.center.x - buttonImage.size.width / 2.f;
    CGFloat y = self.tabBar.frame.size.height - buttonImage.size.height;
    button.frame = CGRectMake(x, y, buttonImage.size.width, buttonImage.size.height);
    
    [self.tabBar addSubview:button];
    
    self.tabBar.backgroundImage = [UIImage new];
    self.tabBar.shadowImage     = [UIImage new];
}

- (void)tappedCreateButton
{
    [self.tabBarController setSelectedIndex:0];
    LandingPageViewController *landingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"landingPageStoryboard"];
    [landingVC performSegueWithIdentifier:@"createMeetingSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
