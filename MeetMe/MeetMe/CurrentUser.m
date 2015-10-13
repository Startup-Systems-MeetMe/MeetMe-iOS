//
//  CurrentUser.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 13/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser

+ (instancetype)sharedInstance
{
    static CurrentUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CurrentUser alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(id)init{
    if(self = [super init]){
        phoneNumber = @"";
        name = @"";
        profileImage = [UIImage imageNamed:@"default_profile_pic"];
    }
    return self;
}

- (void)setPhoneNumber:(NSString*)phone
{
    phoneNumber = phone;
}

@end
