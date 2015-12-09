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
    
    // Add events intervals
    for (EKEvent *event in storeEvents) {
        
        // Skip all-day events
        if (![event isAllDay]) {
            [events addObject:@{@"start":@(event.startDate.epochTime),
                                @"end":@(event.endDate.epochTime)}];
        }
    }
    
    // And add off hours
    [events arrayByAddingObjectsFromArray:[self offHoursForIntervalsFrom:start toDate:end]];
    
    return events;
}

- (NSArray*)offHoursForIntervalsFrom:(NSDate*)start toDate:(NSDate*)end
{
    NSMutableArray *offHours = [[NSMutableArray alloc] init];
    NSCalendar *cal          = [NSCalendar currentCalendar];
    [cal setTimeZone:[NSTimeZone localTimeZone]];
    unsigned unitFlags       = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    // Loop through days and add off hours
    for (NSDate *nextDate = start; [nextDate compare:end] < 0; nextDate = [nextDate dateByAddingTimeInterval:24*60*60]) {
        
        // Set end of interval to same day at 9am
        NSDateComponents *endComp = [cal components:unitFlags fromDate:nextDate];
        [endComp setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
        [endComp setHour:9];
        [endComp setMinute:0];
        [endComp setSecond:0];
        NSDate *tmpEnd = [cal dateFromComponents:endComp];
        
        // Get date of previous day
        NSDateComponents *startComp = [[NSDateComponents alloc] init];
        startComp.day = -1;
        NSDate *tmpStart = [[NSCalendar currentCalendar] dateByAddingComponents:startComp
                                                                 toDate:nextDate
                                                                options:0];
        // Set it to 6pm
        startComp = [cal components:unitFlags fromDate:tmpStart];
        [startComp setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
        [startComp setHour:18];
        [startComp setMinute:0];
        [startComp setSecond:0];
        tmpStart = [cal dateFromComponents:startComp];
        
        // Add it to off hours array
        [offHours addObject:@{@"start":@(tmpStart.epochTime),
                              @"end":@(tmpEnd.epochTime)}];
    }
    
    return nil;
}

- (BOOL)saveMeetingToCalendar:(NSDictionary*)meeting
{
    EKEvent *event = [EKEvent eventWithEventStore:self.store];
    
    // Title
    event.title = [meeting objectForKey:@"name"];
    event.notes = [meeting objectForKey:@"notes"];
    
    // Start Date
    event.startDate = [NSDate dateWithTimeIntervalSince1970:[[[[meeting objectForKey:@"commonFreeTime"]
                                                                       objectAtIndex:0]
                                                                      objectAtIndex:0]
                                                                     doubleValue] / 1000.f];

    // Meeting length
    NSTimeInterval length = [[meeting objectForKey:@"meetingLength"] doubleValue] / 1000.f;

    // End Date
    event.endDate = [event.startDate dateByAddingTimeInterval:length];
    
    // Save to calendar
    [event setCalendar:[self.store defaultCalendarForNewEvents]];
    
    // ... and catch error
    NSError *error;
    [self.store saveEvent:event span:EKSpanThisEvent error:&error];
    return !error;
}


@end
