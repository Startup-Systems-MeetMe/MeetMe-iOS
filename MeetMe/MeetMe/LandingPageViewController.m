//
//  LandingPageViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 28/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "LandingPageViewController.h"
#import <EventKit/EventKit.h>
#import "CurrentUser.h"

@interface LandingPageViewController ()

@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) IBOutlet UIImageView *noMeetingsImage;

@end

@implementation LandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.store = [[EKEventStore alloc] init];
    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        
        if (!granted) return;
        
        [self fetchEvents];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self registerForPushNotifications];
}

- (void)fetchEvents
{
    // Get the appropriate calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // 1 month from now
    NSDateComponents *oneMonthFromNowComponents = [[NSDateComponents alloc] init];
    oneMonthFromNowComponents.month = 1;
    NSDate *oneMonthFromNow = [calendar dateByAddingComponents:oneMonthFromNowComponents
                                                       toDate:[NSDate date]
                                                      options:0];
    
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [self.store predicateForEventsWithStartDate:[NSDate date]
                                                            endDate:oneMonthFromNow
                                                          calendars:nil];
    
    // Fetch all events that match the predicate
    NSArray *storeEvents = [self.store eventsMatchingPredicate:predicate];
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for (EKEvent *event in storeEvents) {
        // Skip all-day events
        if (![event isAllDay]) {
            [events addObject:@{@"title":event.title,
                                @"start":@(floor([event.startDate timeIntervalSince1970] * 1000)),
                                @"end":@(floor([event.endDate timeIntervalSince1970] * 1000))}];
        }
    }
}

- (void)registerForPushNotifications
{
    // Setup Push Notifications
    UIApplication *application = [UIApplication sharedApplication];
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
