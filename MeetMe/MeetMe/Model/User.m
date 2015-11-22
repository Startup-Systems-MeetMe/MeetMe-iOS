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

- (id)initWithName:(NSString *)n andNumber:(NSString *)number andProfileImage:(UIImage *)image
{
    if (self = [super init]) {
        name = n;
        phoneNumber = number;
        profileImage = image;
    }
    return self;
}

@end
