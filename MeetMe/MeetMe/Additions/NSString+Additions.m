//
//  NSString+Additions.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 03/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL)isUSPhoneNumber
{
    NSString *phoneRegex = @"\\({1}([0-9]{3})\\){1}[-\\s]?([0-9]{3})[-]?([0-9]{4})";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [test evaluateWithObject:self];
}

- (NSString*) stringWithoutPhoneFormatting
{
    // Strip off unneeded characters
    NSString *parsedNum = [[self componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    // Remove 1 at the beginning
    if ([parsedNum length] > 0) {
        if ([parsedNum characterAtIndex:0] == '1') {
            parsedNum = [parsedNum substringFromIndex:1];
        }
    }
    return parsedNum;
}

@end
