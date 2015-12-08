//
//  CalendarInterface.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 08/12/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "CalendarInterface.h"
#import "NSDate+Additions.h"
#import <EventKit/EventKit.h>

@interface CalendarInterface ()

@property (strong, nonatomic) EKEventStore *store;
@property (assign, nonatomic) BOOL refusedAccess;

@end

@implementation CalendarInterface

- (id)init
{
    if (self = [super init]) {
        self.store = [[EKEventStore alloc] init];
        [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            _refusedAccess = !granted;
        }];
    }
    return self;
}

- (NSArray*)getEventsIntervalsFrom:(NSDate*)start toDate:(NSDate*)end
{
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [self.store predicateForEventsWithStartDate:start
                                                                 endDate:end
                                                               calendars:nil];
    
    // Fetch all events that match the predicate
    NSArray *storeEvents = [self.store eventsMatchingPredicate:predicate];
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for (EKEvent *event in storeEvents) {
        
        // Skip all-day events
        if (![event isAllDay]) {
            [events addObject:@{@"start":@(event.startDate.epochTime),
                                @"end":@(event.endDate.epochTime)}];
        }
    }
    
    return events;
}


@end
