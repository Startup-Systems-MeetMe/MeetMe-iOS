//
//  NSDate+Additions.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 08/12/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (double)epochTime
{
    return floor([self timeIntervalSince1970] * 1000);
}

- (NSDate*)endOFDay
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay) fromDate:self];
    comp.hour   = 23;
    comp.minute = 59;
    comp.second = 59;
    return [[NSCalendar currentCalendar] dateFromComponents:comp];
}

+ (NSDate*)sundayThisWeek
{
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday
                                                       fromDate:today];
    
    /*
     Create a date components to represent the number of days to subtract from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today is Sunday, subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
    
    // Add a week
    NSDateComponents *nextWeekComp = [[NSDateComponents alloc] init];
    [nextWeekComp setDay:7];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:nextWeekComp toDate:today options:0];
    
    // Then go back to Sunday
    beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract
                                                         toDate:beginningOfWeek options:0];
    
    return beginningOfWeek;
}

@end
