//
//  CurrentUser.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 13/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser

@synthesize phoneNumber;
@synthesize name;
@synthesize profileImage;

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
        profileImage = [[UIImage alloc] init];
    }
    return self;
}

- (NSString *)phoneNumber
{
    return phoneNumber;
}

- (NSString *)name
{
    return name;
}

- (UIImage *)profileImage
{
    return profileImage;
}

- (void)setPhoneNumber:(NSString*)phone
{
    phoneNumber = phone;
}

- (void)setProfilePicture:(UIImage*)image
{
    profileImage = image;
}

- (void)setName:(NSString*)username
{
    name = username;
}

@end
