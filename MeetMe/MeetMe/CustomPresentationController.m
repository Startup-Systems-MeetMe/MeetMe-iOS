//
//  CustomPresentationController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 23/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "CustomPresentationController.h"

@implementation CustomPresentationController

- (BOOL)shouldRemovePresentersView
{
    return YES;
}

- (void)containerViewWillLayoutSubviews
{
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

@end
