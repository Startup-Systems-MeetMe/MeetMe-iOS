//
//  User.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 22/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize name;
@synthesize phoneNumber;
@synthesize profileImage;
@synthesize profilePictureFile;

- (id)initFromDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        name = [dictionary objectForKey:@"name"];
        phoneNumber = [dictionary objectForKey:@"username"];
        profileImage = [UIImage new];
        profilePictureFile = [dictionary objectForKey:@"profilePicture"];
    }
    return self;
}

@end
