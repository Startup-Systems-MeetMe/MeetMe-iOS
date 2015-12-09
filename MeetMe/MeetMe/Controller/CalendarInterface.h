//
//  CalendarInterface.h
//  MeetMe
//
//  Created by Anas Bouzoubaa on 08/12/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarInterface : NSObject

- (NSArray*)getEventsIntervalsFrom:(NSDate*)start toDate:(NSDate*)end;
- (NSArray*)offHoursForIntervalsFrom:(NSDate*)start toDate:(NSDate*)end;
- (BOOL)saveMeetingToCalendar:(NSDictionary*)meeting;

@end
