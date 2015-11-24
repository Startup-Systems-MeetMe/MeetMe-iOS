//
//  LandingPageViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 28/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "LandingPageViewController.h"
#import <EventKit/EventKit.h>

@interface LandingPageViewController ()

@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) IBOutlet UIImageView *noMeetingsImage;

@end

@implementation LandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.store = [[EKEventStore alloc] init];
//    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
//        
//        if (!granted) return;
//        
//        [self fetchEvents];
//    }];
}

//- (void)fetchEvents
//{
//    // Get the appropriate calendar
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    // Create the start date components
//    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
//    oneDayAgoComponents.day = -1;
//    NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
//                                                  toDate:[NSDate date]
//                                                 options:0];
//    
//    // Create the end date components
//    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
//    oneYearFromNowComponents.year = 1;
//    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
//                                                       toDate:[NSDate date]
//                                                      options:0];
//    
//    // Create the predicate from the event store's instance method
//    NSPredicate *predicate = [self.store predicateForEventsWithStartDate:oneDayAgo
//                                                            endDate:oneYearFromNow
//                                                          calendars:nil];
//    
//    // Fetch all events that match the predicate
//    NSArray *events = [self.store eventsMatchingPredicate:predicate];
//    NSMutableArray *titles = [[NSMutableArray alloc] init];
//    for (EKEvent *event in events) {
//        [titles addObject:event.title];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    UIViewController* controller = (UIViewController*)segue.destinationViewController;
//    
//    controller.transitioningDelegate = self.transitionDelegate;
//    controller.modalPresentationStyle = UIModalPresentationCustom;
//    controller.modalPresentationCapturesStatusBarAppearance = YES;
}


@end
