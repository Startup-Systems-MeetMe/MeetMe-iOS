//
//  CustomTransitionDelegate.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 23/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "CustomTransitionDelegate.h"
#import "CustomTransitionAnimator.h"
#import "CustomPresentationController.h"

@implementation CustomTransitionDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [CustomTransitionAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [CustomTransitionAnimator new];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[CustomPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end
