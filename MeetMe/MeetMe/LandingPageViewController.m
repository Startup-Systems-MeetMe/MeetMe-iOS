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
#import "CalendarInterface.h"
#import <Parse/Parse.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIView+Additions.h"

@interface LandingPageViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) NSArray *meetings;

@property (strong, nonatomic) NSString *IdOfMeetingToSave;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation LandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMeetingToSaveCallback:) name:@"NEW_MEETING_TO_SAVE" object:nil];
    
    // Remove cell separators
    self.tableView.tableFooterView = [UIView new];
    
    // Refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull down to refresh" attributes:nil]];
    [self.refreshControl setTintColor:[UIColor colorWithRed:0.49 green:0.50 blue:0.51 alpha:1.0]];
    [self.refreshControl addTarget:self action:@selector(getPendingMeetings) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self getPendingMeetings];
}

- (void)newMeetingToSaveCallback:(NSNotification*)notification
{
    self.IdOfMeetingToSave = [notification.userInfo objectForKey:@"newData"];
    
    [self getPendingMeetings];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self registerForPushNotifications];
    
    [self getPendingMeetings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPendingMeetings) name:@"UPDATE_MEETINGS" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_MEETINGS" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) getPendingMeetings
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.refreshControl beginRefreshing];
//        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        
        NSDictionary *params = @{@"username":[[CurrentUser sharedInstance] phoneNumber]};
        [PFCloud callFunctionInBackground:@"getPendingMeetings" withParameters:params block:^(id _Nullable object, NSError * _Nullable error) {
            
            [SVProgressHUD dismiss];
            [self.refreshControl endRefreshing];
            
            //TODO: Handle Errors
            if (error)
                return;
            
            
            _meetings = [NSArray arrayWithArray:object];
            
            // Sort meetings
            NSSortDescriptor *startSort     = [NSSortDescriptor sortDescriptorWithKey:@"startRange" ascending:YES];
            NSSortDescriptor *endSort       = [NSSortDescriptor sortDescriptorWithKey:@"endRange" ascending:YES];
            NSSortDescriptor *respondedSort = [NSSortDescriptor sortDescriptorWithKey:@"numResponded" ascending:YES];
            _meetings = [_meetings sortedArrayUsingDescriptors:@[respondedSort, startSort, endSort]];
            
            [_tableView reloadData];
            
            // New Meeting to save
            if (self.IdOfMeetingToSave.length > 0) {
                for (PFObject *meeting in _meetings) {
                    
                    // Found meeting
                    if ([[meeting objectId] isEqualToString:self.IdOfMeetingToSave]) {
                        
                        // Try saving to calendar
                        if ([[[CalendarInterface alloc] init] saveMeetingToCalendar:(NSDictionary*)meeting]) {
                            [SVProgressHUD showSuccessWithStatus:@"Saved Meeting to Your iOS Calendar"];
                        } else {
                            [SVProgressHUD showErrorWithStatus:@"Failed saving to calendar"];
                        }
                        self.IdOfMeetingToSave = @"";
                    }
                }
            }
        }];
        
    });
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
    return [UIImage imageNamed:@"landing-empty-fullscreen"];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get meeting
    NSDictionary *meeting = [self.meetings objectAtIndex:indexPath.row];
    return [self isMeetingPending:meeting] ? 139.f : 102.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get meeting
    NSDictionary *meeting = [self.meetings objectAtIndex:indexPath.row];
    BOOL isPending        = [self isMeetingPending:meeting];
    
    // Choose the right type of cell
    UITableViewCell *cell;
    if (!isPending) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"meetingCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"meetingCell"];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"pendingMeetingCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pendingMeetingCell"];
        }
    }
    
    // Cell's subviews
    UIView *contentView          = (UIView*)[cell viewWithTag:100];
    UILabel *titleLabel          = (UILabel*)[cell viewWithTag:101];
    UILabel *participantsLabel   = (UILabel*)[cell viewWithTag:102];
    UIView *squareViewWithShadow = (UIView*)[cell viewWithTag:104];
    UILabel *dateLabel           = (UILabel*)[cell viewWithTag:107];
    if (isPending) {
        UIButton *refuseButton = (UIButton*)[cell viewWithTag:105];
        UIButton *acceptButton = (UIButton*)[cell viewWithTag:106];
        [acceptButton addTarget:self action:@selector(acceptMeeting:) forControlEvents:UIControlEventTouchUpInside];
        [refuseButton addTarget:self action:@selector(refuseMeeting:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Data objects
    NSArray *participants        = [meeting objectForKey:@"participants"];
    NSArray *participantNames    = [participants valueForKey:@"name"];
    NSString *participantsString = [participantNames componentsJoinedByString:@", "];
    
    // Add shadow
    CGRect bounds     = contentView.bounds;
    bounds.size.width = self.view.bounds.size.width - 40.f;
    [self addDropShadowToView:contentView inRect:bounds];
    [self addDropShadowToView:squareViewWithShadow inRect:squareViewWithShadow.bounds];
    
    // Add content
    titleLabel.text        = [meeting objectForKey:@"name"];
    participantsLabel.text = participantsString;
    
    // Add a combined image view
    UIView *combinedImageViews = [[UIView alloc] initWithFrame:squareViewWithShadow.bounds];
    [squareViewWithShadow addSubview:combinedImageViews];
    
    // ... default it to standard profile picture in case no profile pics are found
    [combinedImageViews addSubview:[UIView viewWithMultipleImages:@[[UIImage imageNamed:@"default_profile_pic"]] andSize:squareViewWithShadow.bounds.size]];
    
    // Fetch all profile pictures in background
    NSMutableArray *profilePictures = [[NSMutableArray alloc] init];
    for (id obj in participants) {
        [(PFFile*)[obj objectForKey:@"profilePicture"] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (!error) {
                
                // Add new UIImage to NSArray
                [profilePictures addObject:[UIImage imageWithData:data]];
                
                // Clear all the subviews
                [combinedImageViews.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                
                // Then re-create combined view
                [combinedImageViews addSubview:[UIView viewWithMultipleImages:profilePictures andSize:squareViewWithShadow.bounds.size]];
            }
        }];
    }
    
    // Date for set meetings
    if ([meeting objectForKey:@"set"] == nil) {
        dateLabel.text = [NSString stringWithFormat:@"Pending (%@/%@)", meeting[@"numResponded"], meeting[@"numOfParticipants"]];
    
    } else if ([[meeting objectForKey:@"set"] boolValue]) {
        // Use start date of first common time
        NSDate *firstCommonTime = [NSDate dateWithTimeIntervalSince1970:[[[[meeting objectForKey:@"commonFreeTime"]
                                                                           objectAtIndex:0]
                                                                          objectAtIndex:0]
                                                                         doubleValue] / 1000.f];
        
        // Format date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE MM/dd - HH:mm"];
        [dateFormatter setAMSymbol:@"am"];
        [dateFormatter setPMSymbol:@"pm"];
        dateLabel.text = [dateFormatter stringFromDate:firstCommonTime];
    } else {
        dateLabel.text = @"Failed";
    }
    
    return cell;
}

- (BOOL)isMeetingPending:(NSDictionary*)meeting
{
    if ([meeting objectForKey:@"set"] != nil && [[meeting objectForKey:@"set"] boolValue] == false) {
        return false;
    }

    // Get self's position in participants array
    int positionOfSelf = 0; // breaks if self not in participants
    for (int i=0; i < [[meeting objectForKey:@"participants"] count]; i++) {
        PFUser *user = [[meeting objectForKey:@"participants"] objectAtIndex:i];
        if ([[user objectForKey:@"username"] isEqualToString:[[CurrentUser sharedInstance] phoneNumber]]) {
            positionOfSelf = i;
            break;
        }
    }
    
    // Is meeting waiting for my response
    return [[[meeting objectForKey:@"attendance"] objectAtIndex:positionOfSelf] isEqualToString:@"-"];
}

- (void)acceptMeeting:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (!indexPath)
        return;

    [self updateMeetingWithAttendance:YES meeting:[self.meetings objectAtIndex:indexPath.row]];
}

- (void)refuseMeeting:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (!indexPath)
        return;
    
    [self updateMeetingWithAttendance:NO meeting:[self.meetings objectAtIndex:indexPath.row]];
}

- (void)updateMeetingWithAttendance:(BOOL)attending meeting:(NSDictionary*)meeting
{
    PFObject *m = (PFObject*)meeting;
    NSString *accept  = attending ? @"YES" : @"NO";
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[[meeting objectForKey:@"startRange"] doubleValue] / 1000.0];
    NSDate *endDate   = [NSDate dateWithTimeIntervalSince1970:[[meeting objectForKey:@"endRange"] doubleValue] / 1000.0];
    NSArray *calendar = [[[CalendarInterface alloc] init] getEventsIntervalsFrom:startDate toDate:endDate];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [[CurrentUser sharedInstance] phoneNumber], @"username",
                                   accept, @"accept",
                                   m.objectId, @"meetingId",
                                   nil];
    if (calendar.count > 0 && attending) {
        [params setObject:calendar forKey:@"calendar"];
    } else {
        [params setObject:@[] forKey:@"calendar"];
    }
    
    // Loading
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    
    // Update Meeting on Parse
    [PFCloud callFunctionInBackground:@"updatePendingMeeting" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        
        [SVProgressHUD dismiss];

        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getPendingMeetings];
            });
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Sorry, try again later."];
        }
    }];
}

- (void)addDropShadowToView:(UIView*)view inRect:(CGRect)bounds
{
    UIBezierPath *shadowPath        = [UIBezierPath bezierPathWithRect:bounds];
    
    view.layer.masksToBounds = NO;
    view.layer.shadowPath    = shadowPath.CGPath;
    view.layer.shadowColor   = [UIColor blackColor].CGColor;
    view.layer.shadowOffset  = CGSizeMake(0, 0);
    view.layer.shadowOpacity = 0.2f;
    view.layer.shadowRadius  = 5;
}

@end
