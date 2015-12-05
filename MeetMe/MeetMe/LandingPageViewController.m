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
#import "Meeting.h"
#import <Parse/Parse.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface LandingPageViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) NSArray *meetings;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation LandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Remove cell separators
    self.tableView.tableFooterView = [UIView new];
    
    // Refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull down to refresh" attributes:nil]];
    [self.refreshControl setTintColor:[UIColor colorWithRed:0.49 green:0.50 blue:0.51 alpha:1.0]];
    [self.refreshControl addTarget:self action:@selector(getPendingMeetings) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.store = [[EKEventStore alloc] init];
    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        
        if (!granted) return;
        
        [self fetchEvents];
    }];
    
    [self getPendingMeetings];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self registerForPushNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (void) getPendingMeetings
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD show];
    });

    NSDictionary *params = @{@"username":@"3472252451"};
    [PFCloud callFunctionInBackground:@"getPendingMeetings" withParameters:params block:^(id _Nullable object, NSError * _Nullable error) {
        
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
        
        //TODO: Handle Errors
        if (error) {
            NSLog(@"Error found: %@", error.localizedDescription);
            return;
        }
        
        _meetings = [NSArray arrayWithArray:object];
        [_tableView reloadData];
        
    }];
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

//------------------------------------------------------------------------------------------
#pragma mark - Empty Table View -
//------------------------------------------------------------------------------------------

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"landing-empty"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.meetings.count == 0;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return NO;
}

//------------------------------------------------------------------------------------------
#pragma mark - UITableView -
//------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.meetings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"meetingCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    UIView *contentView    = (UIView*)[cell viewWithTag:100];
    UILabel *titleLabel    = (UILabel*)[cell viewWithTag:101];
    UILabel *participants  = (UILabel*)[cell viewWithTag:102];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:103];
    UIView *fakeImageView  = (UIView*)[cell viewWithTag:104];
    
    NSDictionary *meeting = [self.meetings objectAtIndex:indexPath.row];
    
    // Add shadow
    CGRect bounds     = contentView.bounds;
    bounds.size.width = self.view.bounds.size.width - 50.f;
    contentView   = [self viewWithDropShadow:contentView inRect:bounds];
    fakeImageView = [self viewWithDropShadow:fakeImageView inRect:fakeImageView.bounds];
    
    // Add content
    titleLabel.text   = [meeting objectForKey:@"name"];
    participants.text = [[CurrentUser sharedInstance] name];
    imageView.image   = [[CurrentUser sharedInstance] profileImage];
    
    return cell;
}

- (UIView*)viewWithDropShadow:(UIView*)contentView inRect:(CGRect)bounds
{
    UIBezierPath *shadowPath        = [UIBezierPath bezierPathWithRect:bounds];
    
    contentView.layer.masksToBounds = NO;
    contentView.layer.shadowPath    = shadowPath.CGPath;
    contentView.layer.shadowColor   = [UIColor blackColor].CGColor;
    contentView.layer.shadowOffset  = CGSizeMake(0, 0);
    contentView.layer.shadowOpacity = 0.2f;
    contentView.layer.shadowRadius  = 3;
    
    return contentView;
}

@end
