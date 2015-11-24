//
//  TabBarController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 10/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "TabBarController.h"
#import "LandingPageViewController.h"
#import "CustomTransitionDelegate.h"
#import "NewMeetingNavigationViewController.h"

@interface TabBarController ()

@property (nonatomic) CustomTransitionDelegate* transitionDelegate;

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Default tab
    [self setSelectedIndex:1];
    
    // Disable all tabs but 1 and 4
    for (int i = 0; i < self.tabBar.items.count; i++) {
        if (i != 1 && i != 4) [[self.tabBar.items objectAtIndex:i] setEnabled:NO];
    }
    
    // Center '+' button
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"Create-unselected"];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"Create-selected"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tappedCreateButton) forControlEvents:UIControlEventTouchUpInside];
    CGFloat x = self.tabBar.center.x - buttonImage.size.width / 2.f;
    CGFloat y = self.tabBar.frame.size.height - buttonImage.size.height;
    button.frame = CGRectMake(x, y, buttonImage.size.width, buttonImage.size.height);
    [self.tabBar addSubview:button];

    // Get rid of line behind tab
    self.tabBar.backgroundImage = [UIImage new];
    self.tabBar.shadowImage     = [UIImage new];
}

- (void)tappedCreateButton
{
    [self setSelectedIndex:1];
    NewMeetingNavigationViewController *navController = (NewMeetingNavigationViewController*)[[self viewControllers] objectAtIndex:1];
    navController.transitioningDelegate = self.transitioningDelegate;
    navController.modalPresentationStyle = UIModalPresentationCustom;
    navController.modalPresentationCapturesStatusBarAppearance = YES;
    [navController presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"selectContactsNavigationVC"] animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
#pragma mark - Transitions -
//------------------------------------------------------------------------------------------

- (CustomTransitionDelegate*)transitionDelegate
{
    if (!_transitionDelegate) {
        _transitionDelegate = [CustomTransitionDelegate new];
    }
    return _transitionDelegate;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController* controller = (UIViewController*)segue.destinationViewController;
    
    controller.transitioningDelegate = self.transitionDelegate;
    controller.modalPresentationStyle = UIModalPresentationCustom;
    controller.modalPresentationCapturesStatusBarAppearance = YES;
}


@end
