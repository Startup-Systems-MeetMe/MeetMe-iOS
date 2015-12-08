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

@end
