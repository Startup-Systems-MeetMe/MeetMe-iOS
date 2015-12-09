//
//  NSDate+Additions.h
//  MeetMe
//
//  Created by Anas Bouzoubaa on 08/12/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

- (double)epochTime;
- (NSDate*)endOFDay;
+ (NSDate*)sundayThisWeek;

@end
