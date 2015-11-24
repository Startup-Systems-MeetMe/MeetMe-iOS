//
//  NewMeetingNavigationViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 23/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "NewMeetingNavigationViewController.h"
#import "CustomTransitionDelegate.h"

@interface NewMeetingNavigationViewController ()

@property (nonatomic) CustomTransitionDelegate* transitionDelegate;

@end

@implementation NewMeetingNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UIStoryboardSegue*)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    return [toViewController segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
}


@end
